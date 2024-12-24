{ pkgs, modulesPath, lib, config, ... }@args:
let cfg = config.bdx0.base;
in {
  imports = [ ];
  options.bdx0.incus = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "This is the config of incus";
    };
  };
  config = lib.mkIf cfg.enable {

    virtualisation.incus.enable = true;
    virtualisation.incus.ui.enable = true;
    virtualisation.incus.preseed = {
      networks = [{
        config = {
          "ipv4.address" = "10.0.100.1/24";
          "ipv4.nat" = "true";
        };
        name = "incusbr0";
        type = "bridge";
      }];
      profiles = [{
        devices = {
          eth0 = {
            name = "eth0";
            network = "incusbr0";
            type = "nic";
          };
          root = {
            path = "/";
            pool = "/default";
            size = "35GiB";
            type = "disk";
          };
        };
        name = "default";
      }];
      storage_pools = [{
        config = {
          lvm.thinpool_name = "IncusThinPool";
          lvm.vg.force_reuse = true;
          lvm.vg_name = "default";
          source = "default";
        };
        driver = "lvm";
        default = "default";
      }];
    };
    networking.nftables.enable = true;
  };
}
