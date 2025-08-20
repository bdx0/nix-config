{ inputs, config, pkgs, lib, name, nodes, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {
    boot.loader.grub.device = "/dev/vda";
    boot.kernelModules =
      [ "overlay" "br_netfilter" "ip=dhcp" "kvm-intel" "wl" ];
    boot.initrd.availableKernelModules = [
      "virtio_blk"
      "virtio_pci"
      "sr_mod"
      "nvme"
      "xhci_pci"
      "ehci_pci"
      "ohci_pci"
      "ehci_hcd"
      "uhci_hcd"
      "ohci_hcd"
      "ahci"
      "usb_storage"
      "usbcore"
      "sd_mod"
      "scsi_mod"
      "usbhid"
      "uas"
      "vmw_pvscsi"
      "xen_blkfront"
      "ata_piix"
    ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    networking.domain = "cephlina.bdx0.io.vn";
    bdx0.vfio.IOMMUType = "intel";

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    nixpkgs.config.allowUnfree = true;

  };
}
