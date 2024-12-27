{ inputs, pkgs, lib, ... }: {
  imports = [ inputs.nixosModules.common ];

  config = {
    boot.initrd.availableKernelModules =
      [ "xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "ip=dhcp" ];
    boot.extraModulePackages = [ ];
    fileSystems."/" = {
      device = "/dev/mapper/ubuntu--vg-ubuntu--lv";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F640-FAAE";
      fsType = "vfat";
    };

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;

    networking.hostName = "nix-infect";
    networking.domain = "nix-infect.bdx0.io.vn";

    environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
  };
}
