{ inputs, ... }: {
  imports =
    [ inputs.self.nixosModules.common inputs.self.nixosModules.disko.btrfs ];
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
      device = "/dev/disk/by-uuid/525e3a71-757e-49ab-b271-e47a73ce9641";
      fsType = "ext4";
      # options = [ "nouuid" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F640-FAAE";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.libvirtd.enable = false;
    bdx0.vfio.enable = false;
    bdx0.container.engine = "docker";

    nixpkgs.config.allowUnfree = true;

    programs.nix-ld.enable = true;
  };
}
