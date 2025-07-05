{ config, pkgs, lib, ... }:
let cfg = config.nyx.gui;
in
{
  config = lib.mkIf cfg.enable {
    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
    ];
    boot.kernelModules = with config.boot.kernelModules; [
      "vfio-pci"
      "vfio_iommu_type1"
      "vfio"
    ];

    environment.systemPackages = with pkgs; [
      virt-manager
      libguestfs-with-appliance # mount vm disk image
    ];

    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu.swtpm.enable = true; # Enable TPM support for VMs
    virtualisation.libvirtd.hooks.qemu = {
      "hooks.sh" = pkgs.writeShellScript "hooks.sh" (builtins.readFile ./qemu_hooks.tmpl.sh);
    };
  };
}
