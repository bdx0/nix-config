{ config, lib, ... }@args:
let
  cfg = config.bdx0.hardware;
  hostname = (if (builtins.hasAttr "meta" args) then
    args.meta.hostname
  else if (builtins.hasAttr "name" args) then
    args.name
  else
    "unknown");
in {
  options.bdx0.hardware = {
    enable = lib.mkEnableOption "Enable hardware configuration";
    type = lib.mkOption {
      description = " ";
      default = "intel";
      type = lib.types.enum [ "intel" "amd" ];
    };
  };
  config = lib.mkIf cfg.enable {
    boot.kernel.sysctl = {
      "fs.file-max" = 1000000;
      "fs.inotify.max_user_instances" = 1000000;
    };
    boot.initrd.kernelModules =
      [ "nvme" "dm-snapshot" "dm-raid" "dm-cache-default" ]; # "wl"
    boot.kernelModules =
      [ "ip=dhcp" "wl" "dm-raid" "dm-snapshot" "dm-cache-default" ]
      ++ (lib.optional (cfg.type == "intel") "kvm-intel")
      ++ (lib.optional (cfg.type == "amd") "kvm-amd");
    # "kvm-amd" "kvm-intel"
    boot.supportedFilesystems = {
      btrfs = true;
      zfs = lib.mkForce false;
      ntfs = true;
    };
    services.lvm.boot.thin.enable = true;
    # when using thin provisioning or caching

    swapDevices = [{
      device = "/.swapfile";
      size = 32 * 1024; # 32GB
    }];

    hardware.cpu.${cfg.type}.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    boot.initrd.availableKernelModules = [ ]
      ++ config.bdx0.${hostname}.initrd.availableKernelModules;
  };
}
