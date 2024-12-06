{ inputs, config, pkgs, lib, name, nodes, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {
    boot.initrd.availableKernelModules = [
      "virtio_pci"
      "sr_mod"
      "usbhid"
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "uas"
      "sd_mod"
    ];
    boot.kernelParams = [ "amd_iommu=on" ];
    boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];
    # "https://forum.level1techs.com/t/nixos-vfio-pcie-passthrough/130916"
    boot.kernelModules =
      [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" ];

    fileSystems."/" = {
      device = "/dev/mapper/bobo--vg-root";
      fsType = "ext4";
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/F829-4EB1";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/run/media/Data1T" = {
      device = "/dev/sdd2";
      fsType = "ntfs-3g";
      options = [ "rw" "uid=1000" ];
    };
    swapDevices =
      [{ device = "/dev/disk/by-uuid/b5a4686e-7d68-4fbb-b335-c837a48f40a6"; }];

    hardware.cpu.amd.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    # boot.loader.systemd-boot.enable = true;
    # boot.loader.efi.canTouchEfiVariables = true;

    networking.domain = "bobo.bdx0.io.vn";
    common.dvm.enable = true;

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    nixpkgs.config.allowUnfree = true;
  };
}
