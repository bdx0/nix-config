{ lib, config, modulesPath, ... }: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "nvme" "usb_storage" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "wl" ];
  boot.kernelModules = [ "kvm-intel" "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
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
}
