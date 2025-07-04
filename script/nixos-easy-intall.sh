#!/usr/bin/env bash
# Description: A simple script to install NixOS with basic configurations.

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
proxy=""
while getopts "d:u:p:" opt; do
  case $opt in
    d) device="$OPTARG" ;;
    u) username="$OPTARG" ;;
    p) proxy="$OPTARG" ;;
    *) echo "Usage: $0 [-d device] [-u username]" >&2; exit 1 ;;
  esac
done

check_empty "$device" "Device"
check_empty "$username" "Username"
if [[ -n "$proxy" ]]; then
  export http_proxy="$proxy"
  export https_proxy="$proxy"
  echo "Using proxy: $proxy"
fi

if [[ "$device" =~ [0-9]$ ]]; then
  boot_device="${device}p1"
  root_device="${device}p2"
else
  boot_device="${device}1"
  root_device="${device}2"
fi


# ==== Partitioning the disk ====
# dos partition table for BIOS systems
# parted -s "$device" \
#   mklabel msdos \
#   mkpart primary ext4 1MiB 512MiB \
#   mkpart primary ext4 512MiB 100%

# # gpt partition table for UEFI systems
parted -s "$device" \
  mklabel gpt \
  mkpart primary fat32 1MiB 512MiB \
  set 1 esp on \
  mkpart primary ext4 512MiB 100%

mkfs.fat -F 32 "$boot_device"
fatlabel "$boot_device" NIXBOOT
mkfs.ext4 "$root_device" -L NIXROOT

# ==== Mounting the partitions ====
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot

# ==== Setting up the NixOS configuration ====
nixos-generate-config --root /mnt

basic_config=$(cat <<EOF
{ config, pkgs, lib, ... }:
{
  boot.loader.grub.device = "${device}"; # or "nodev" for efi only
  time.timeZone = "Asia/Shanghai";
  users.users.${username} = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
     initialPassword = "pw123"; # Set a default password
  };

  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.openssh.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = true; # 让 glibc 能解析 .local 域名
    publish.enable = true; # 如果你想让自己这台机器也被 .local 找到
    publish.addresses = true;
    publish.workstation = true;
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    clang
    gnumake
  ];
}
EOF)
echo "$basic_config" | tee /mnt/etc/nixos/base.nix

# ==== import the configuration ====
cfg="/mnt/etc/nixos/configuration.nix"
pos_line="./hardware-configuration.nix"
insert_line="    ./base.nix"

# 检查是否已存在，避免重复
if ! grep -qF "$insert_line" "$cfg"; then
  # 找到 system.stateVersion 所在行号
  line_num=$(grep -n "$pos_line" "$cfg" | cut -d: -f1 | head -n1)

  if [ -n "$line_num" ]; then
    sed -i "${line_num}a\\$insert_line" "$cfg"

    echo "[+] Successfully inserted '$insert_line' into $cfg"
  else
    echo "[x] Could not find '$pos_line' in $cfg"
    exit 1
  fi
else
  echo "[!] '$insert_line' already exists in $cfg"
fi


# ==== Installing NixOS ====
cd /mnt && nixos-install --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
