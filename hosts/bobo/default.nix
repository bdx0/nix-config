{ self, config, pkgs, lib, name, modulesPath, nodes, ... }: {
  imports = [ self.nixosModules.common ];
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

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  networking.domain = "bobo.bdx0.io.vn";

  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = "figurine ${name}";
  nixpkgs.config.allowUnfree = true;
  microvm.vms = {
    # test = {
    #   inherit pkgs;
    #   config = { };
    #   imports = [
    #     ../../modules/core/common.nix
    #     self.inputs.microvm.nixosModules.microvm
    #     (modulesPath + "/profiles/qemu-guest.nix")
    #     (modulesPath + "/installer/scan/not-detected.nix")
    #   ];

    # };
  };
}
