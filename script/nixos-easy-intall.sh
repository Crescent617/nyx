# Description: A simple script to install NixOS with basic configurations.
#!/usr/bin/env bash

set -euo pipefail

check_empty() {
  if [[ -z "$1" ]]; then
    echo "Error: $2 cannot be empty." >&2
    exit 1
  fi
}

# ==== Options ===
device=""
username=""
while getopts "d:u:" opt; do
  case $opt in
    d) device="$OPTARG" ;;
    u) username="$OPTARG" ;;
    *) echo "Usage: $0 [-d device] [-u username]" >&2; exit 1 ;;
  esac
done

check_empty "$device" "Device"
check_empty "$username" "Username"

boot_device="${device}1"
root_device="${device}2"

# ==== Partitioning the disk ====
# TODO: test partition
# dos partition table for BIOS systems
sudo parted "$device" --script -- \
  mklabel msdos \
  mkpart primary ext4 1MiB 501MiB \
  mkpart primary ext4 501MiB 100%

# # gpt partition table for UEFI systems
# sudo parted /dev/sdX --script -- \
#   mklabel gpt \
#   mkpart ESP fat32 1MiB 501MiB \
#   set 1 esp on \
#   mkpart primary ext4 501MiB 100%

sudo mkfs.fat -F 32 "$boot_device"
sudo fatlabel "$boot_device" NIXBOOT
sudo mkfs.ext4 "$root_device" -L NIXROOT

# ==== Mounting the partitions ====
sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot

# ==== Setting up the NixOS configuration ====
sudo nixos-generate-config --root /mnt

basic_config=$(cat <<EOF
{ config, pkgs, ... }:
{
  boot.loader.grub.device = "${device}"; # or "nodev" for efi only
  time.timeZone = "Asia/Shanghai";
  users.users.${user_name} = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
     initialPassword = "pw123"; # Set a default password
  };

  nix.settings.substituters = lib.mkForce [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];

  services.openssh.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
  ];
}
EOF)
echo "$basic_config" | sudo tee /mnt/etc/nixos/base.nix

# ==== import the configuration ====
cfg="/mnt/etc/nixos/configuration.nix"
insert_line="imports = [ ./base.nix ];"

# 检查是否已存在，避免重复
if ! grep -qF "$insert_line" "$cfg"; then
  # 找到 system.stateVersion 所在行号
  line_num=$(grep -n "system\.stateVersion =" "$cfg" | cut -d: -f1 | head -n1)

  if [ -n "$line_num" ]; then
    sudo sed -i "${line_num}a\\  $insert_line" "$cfg"

    echo "[+] Successfully inserted imports after system.stateVersion"
  else
    echo "[x] Could not find 'system.stateVersion' in $cfg"
    exit 1
  fi
else
  echo "[!] \"$insert_line\" already exists in $cfg"
fi


# ==== Installing NixOS ====
cd /mnt && sudo nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
