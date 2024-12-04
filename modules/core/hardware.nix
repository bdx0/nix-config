{ config, lib, ... }: {
  options = { };
  config = {
    boot.initrd.kernelModules = [ "dm-snapshot" "wl" ];
    boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    boot.kernelModules = [ "ip=dhcp" "kvm-amd" "kvm-intel" "wl" ];
    boot.supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
  };
}
