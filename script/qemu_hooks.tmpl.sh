#!/usr/bin/env bash

# This script handles GPU passthrough preparation and release events for QEMU virtual machines.
# It is triggered by QEMU hooks and performs tasks such as stopping the display manager,
# unbinding the GPU from the host system, and loading the VFIO kernel module for passthrough.
# Additionally, it manages re-binding the GPU and restarting the display manager after use.
#
# Usage:
#   qemu_hooks.tmpl.sh <guest_name> <event> <sub_event>
#
# Arguments:
#   guest_name - Name of the guest virtual machine. (only when guest_name end with "pt")
#   event      - Main event type (e.g., 'prepare' or 'release').
#   sub_event  - Sub-event type (e.g., 'begin' or 'end').

set -eu

export PATH=/run/current-system/sw/bin:/usr/bin:$PATH

# ==== CONFIG ====
pci_devices=(
  "pci_0000_01_00_0" # GPU
  "pci_0000_01_00_1" # Audio
  "pci_0000_01_00_2" # USB Controller
  "pci_0000_01_00_3" # USB Controller
)

logfile="/tmp/qemu_hooks.log"

# ==== Args ====
GUEST_NAME="$1"
EVENT="$2"
SUB_EVENT="$3"

info() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1" | tee -a "$logfile"
}

info "[QEMU_HOOK_BEGIN] guest=$GUEST_NAME event=$EVENT sub_event=$SUB_EVENT"

gpu_passthru=0
if [[ "$GUEST_NAME" =~ pt$ ]]; then
  gpu_passthru=1
fi

if [[ $gpu_passthru == 1 && "$EVENT" == "prepare" && "$SUB_EVENT" == "begin" ]]; then
  info "Starting GPU Passthrough Preparation"
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
  for device in "${pci_devices[@]}"; do
    virsh nodedev-detach "$device"
  done

  # Load VFIO Kernel Module
  modprobe vfio-pci
  info "VFIO Kernel Module Loaded"
fi

if [[ $gpu_passthru == 1 && "$EVENT" == "release" && "$SUB_EVENT" == "end" ]]; then
  info "Starting GPU Passthrough Release"

  # Re-Bind GPU to Nvidia Driver
  info "Stopping VFIO Kernel Module"
  for ((i = ${#pci_devices[@]} - 1; i >= 0; i--)); do
    virsh nodedev-reattach "${pci_devices[i]}"
  done

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
