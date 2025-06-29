#!/usr/bin/env bash

set -x

# 如果是 system scope 且当前不是 root，则用 sudo 重新执行
if [[ "$EUID" -ne "0" ]]; then
  exec sudo "$0" "$@"
fi

GUEST_NAME="$1"
EVENT="$2"
SUB_EVENT="$3"

guest=win11
logfile="/tmp/qemu_hooks.log"

info() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1" >>"$logfile"
}

info "[QEMU Hook] guest=$GUEST_NAME event=$EVENT sub_event=$SUB_EVENT"

if [[ "$GUEST_NAME" == "$guest" && "$EVENT" == "prepare" && "$SUB_EVENT" == "begin" ]]; then
  info "Preparing GPU for Passthrough"
  # Stop display manager
  systemctl stop display-manager.service
  ## Uncomment the following line if you use GDM
  killall gdm-x-session
  killall niri

  sleep 2

  info "Rmmod Nvidia Modules"
  rmmod nvidia_drm
  rmmod nvidia_uvm
  rmmod nvidia_modeset
  rmmod nvidia

  # Unbind VTconsoles
  echo 0 >/sys/class/vtconsole/vtcon0/bind
  echo 0 >/sys/class/vtconsole/vtcon1/bind

  # Unbind EFI-Framebuffer
  echo efi-framebuffer.0 >/sys/bus/platform/drivers/efi-framebuffer/unbind

  # Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
  sleep 2

  # Unbind the GPU from display driver
  info "Unbinding GPU from display driver"
  virsh nodedev-detach pci_0000_01_00_0
  virsh nodedev-detach pci_0000_01_00_1
  virsh nodedev-detach pci_0000_01_00_2
  virsh nodedev-detach pci_0000_01_00_3

  # Load VFIO Kernel Module
  modprobe vfio-pci
  info "VFIO Kernel Module Loaded"

  info "Finish Preparing GPU for Passthrough"
fi

if [[ "$GUEST_NAME" == "$guest" && "$EVENT" == "release" && "$SUB_EVENT" == "end" ]]; then
  info "Releasing GPU from Passthrough"

  # Re-Bind GPU to Nvidia Driver
  info "Stopping VFIO Kernel Module"
  virsh nodedev-reattach pci_0000_01_00_3
  virsh nodedev-reattach pci_0000_01_00_2
  virsh nodedev-reattach pci_0000_01_00_1
  virsh nodedev-reattach pci_0000_01_00_0

  # Reload nvidia modules
  info "Reloading Nvidia Modules"
  modprobe nvidia
  modprobe nvidia_modeset
  modprobe nvidia_uvm
  modprobe nvidia_drm

  # Rebind VT consoles
  echo 1 >/sys/class/vtconsole/vtcon0/bind
  # Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
  #echo 1 > /sys/class/vtconsole/vtcon1/bind

  nvidia-xconfig --query-gpu-info >/dev/null 2>&1
  echo "efi-framebuffer.0" >/sys/bus/platform/drivers/efi-framebuffer/bind

  # Restart Display Manager
  systemctl start display-manager.service
  info "Finish Releasing GPU from Passthrough"
fi
