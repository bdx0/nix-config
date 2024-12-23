{ config, lib, ... }: {
  options = { };
  config = {
    boot.kernel.sysctl = {
      "fs.file-max" = 8192;
      "fs.inotify.max_user_instances" = 8192;
    };
    boot.initrd.kernelModules =
      [ "nvme" "dm-snapshot" "wl" "dm-raid" "dm-cache-default" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
      config.boot.kernelPackages.rtl8192eu
    ];
    boot.kernelModules = [
      "ip=dhcp"
      "wl"
      "dm-raid"
      "dm-snapshot"
      "dm-cache-default"
    ]; # "kvm-amd" "kvm-intel"
    boot.supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
    services.lvm.boot.thin.enable =
      true; # when using thin provisioning or caching

    swapDevices = [
      # { device = "/dev/disk/by-uuid/b5a4686e-7d68-4fbb-b335-c837a48f40a6"; }
      {
        device = "/.swapfile";
        size = 32 * 1024; # 32GB
      }
    ];
  };
}
