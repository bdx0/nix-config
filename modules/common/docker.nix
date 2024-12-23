{ config, lib, pkgs, ... }:
let cfg = config.bdx0.docker;
in {
  options.bdx0.docker = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "";
    };
  };
  config = lib.mkIf cfg.enable {
    # users.extraGroups.docker.members = [ "dd" ];
    # environment.persistence = lib.mkIf cfg.persistence.enable {
    #   "/persist" = { directories = [ "/var/lib/docker" ]; };
    # };
    virtualisation = {
      docker = {
        enable = true;
        enableOnBoot = true;
        # enableNvidia = true;
        rootless = {
          enable = false;
          setSocketVariable = true;
        };
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        # storageDriver = "btrfs";
        daemon.settings.features.cdi = true;
        package = pkgs.docker_27;
      };

      containers.cdi.dynamic.nvidia.enable = true;
    };
    services.dockerRegistry.enable = true;
  };
}
