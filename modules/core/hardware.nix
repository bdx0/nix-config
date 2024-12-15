{ config, lib, ... }: {
  options = { };
  config = {
    boot.kernel.sysctl = {
      "fs.file-max" = 8192;
      "fs.inotify.max_user_instances" = 8192;
    };
    boot.initrd.kernelModules = [ "dm-snapshot" "wl" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
      config.boot.kernelPackages.rtl8192eu
    ];
    boot.kernelModules = [ "ip=dhcp" "wl" ]; # "kvm-amd" "kvm-intel"
    boot.supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };

    swapDevices = [
      # { device = "/dev/disk/by-uuid/b5a4686e-7d68-4fbb-b335-c837a48f40a6"; }
      {
        device = "/.swapfile";
        size = 32 * 1024; # 32GB
      }
    ];
  };
}
