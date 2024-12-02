{ config, pkgs, lib, name, modulesPath, ... }: {
  imports = [
    # ./hardware-configuration.nix
    ../../modules/core/common.nix

    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "nvme" "usb_storage" ];
  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/2BF7-EA6A";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/" = {
    device = "/dev/mapper/lina--vg-root";
    fsType = "ext4";
  };
  swapDevices = [ ];
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;

  # config with efiInstallAsRemovable = true
  boot.loader.efi.canTouchEfiVariables = true;

  # boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.useOSProber = true;
  # boot.loader.grub.efiInstallAsRemovable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "lina.bdx0.io.vn";

  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = "figurine ${name}";
  environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
}
