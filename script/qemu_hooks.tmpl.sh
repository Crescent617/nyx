#!/usr/bin/env bash

set -e

export PATH=/run/current-system/sw/bin:/usr/bin:$PATH

GUEST_NAME="$1"
EVENT="$2"
SUB_EVENT="$3"

guest=win11
logfile="/tmp/qemu_hooks.log"

info() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$logfile"
}

info "[QEMU_HOOK_BEGIN] guest=$GUEST_NAME event=$EVENT sub_event=$SUB_EVENT"
info "[QEMU_HOOK_USER] user=$(whoami) id=$(id -u) group=$(id -g) groups=$(id -G)"

if [[ "$GUEST_NAME" == "$guest" && "$EVENT" == "prepare" && "$SUB_EVENT" == "begin" ]]; then
  # Stop display manager
  systemctl stop display-manager.service
  ## Uncomment the following line if you use GDM
  killall gdm-x-session || true
  killall niri || true

  # countdown to allow the display manager to stop
  for i in {1..20}; do
    info "Waiting for nvidia_drm to idle... $i"
    nv_drm_in_use=$(lsmod | awk '/^nvidia_drm/ {print $3}')
    if [[ "$nv_drm_in_use" == "0" ]]; then
      break
    fi
    sleep 1
  done

  info "Rmmod Nvidia Modules"
  rmmod nvidia_drm
  rmmod nvidia_uvm
  rmmod nvidia_modeset
  rmmod nvidia

  # Unbind VTconsoles
  echo 0 >/sys/class/vtconsole/vtcon0/bind || true
  echo 0 >/sys/class/vtconsole/vtcon1/bind || true

  # Unbind EFI-Framebuffer
  echo efi-framebuffer.0 >/sys/bus/platform/drivers/efi-framebuffer/unbind || true

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
fi

if [[ "$GUEST_NAME" == "$guest" && "$EVENT" == "release" && "$SUB_EVENT" == "end" ]]; then
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
  echo 1 >/sys/class/vtconsole/vtcon0/bind || true
  # Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
  #echo 1 > /sys/class/vtconsole/vtcon1/bind

  nvidia-xconfig --query-gpu-info >/dev/null 2>&1 || true
  echo "efi-framebuffer.0" >/sys/bus/platform/drivers/efi-framebuffer/bind || true

  # Restart Display Manager
  systemctl start display-manager.service
fi

info "[QEMU_HOOK_END] guest=$GUEST_NAME event=$EVENT sub_event=$SUB_EVENT"
