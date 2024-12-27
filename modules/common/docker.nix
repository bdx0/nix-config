{ config, lib, pkgs, ... }:
let cfg = config.bdx0.docker;
in {
  options.bdx0.docker = {
    enable = lib.mkEnableOption "Docker";
    nvidia = { enable = lib.mkEnableOption "docker with nvidia support"; };
    storageDriver = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "aufs"
        "btrfs"
        "devicemapper"
        "overlay"
        "overlay2"
        "zfs"
      ]);
      default = null; # aufs btrfs overlay2 zfs overlay
      description = "docker storage driver";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # users.extraGroups.docker.members = [ "dd" ];
      # environment.persistence = lib.mkIf cfg.persistence.enable {
      #   "/persist" = { directories = [ "/var/lib/docker" ]; };
      # };
      boot.kernelModules = [ "overlay" "br_netfilter" ];
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
          storageDriver = cfg.storageDriver;
          package = pkgs.docker_27;
        };

      };
      services.dockerRegistry.enable = true;
    })
    (lib.mkIf cfg.nvidia.enable {
      virtualisation.docker.daemon.settings.features.cdi = cfg.nvidia.enable;
      virtualisation.containers.cdi.dynamic.nvidia.enable = cfg.nvidia.enable;
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      hardware.nvidia.open = true;
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.powerManagement.enable = true;
      # hardware.nvidia.powerManagement.finegrained = true;
      hardware.nvidia.nvidiaSettings = false;
      hardware.nvidia-container-toolkit.enable = true;
      hardware.graphics.enable = true;
    })
  ];
}
