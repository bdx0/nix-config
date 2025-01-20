{ config, lib, pkgs, options, ... }:
let cfg = config.bdx0.container;
in {
  options.bdx0.container = {
    engine = lib.mkOption {
      description = "Which is the engine turn on?";
      type = lib.types.enum [ "podman" "docker" "" ];
      default = "";
    };
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
    {
      virtualisation.docker.enable = (cfg.engine == "docker");
      virtualisation.podman.enable = (cfg.engine == "podman");
      users.extraGroups.docker.members = [ "dd" "code" ];
      boot.kernelModules = [ "overlay" "br_netfilter" ];
      virtualisation.podman = {
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        # dockerCompat = true;
        # dockerSocket = { enable = true; };
      };
      virtualisation.docker = {
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
        enableOnBoot = true;
        #   extraOptions = "--registry-mirror=https://mirror.gcr.io --add-runtime crun=${pkgs.crun}/bin/crun --default-runtime=crun";
        # enableNvidia = lib.mkIf
        #   (builtins.any (v: v == "nvidia") config.services.xserver.videoDrivers)
        #   true;
        rootless = {
          enable = false;
          setSocketVariable = true;
        };
        storageDriver = cfg.storageDriver;
        package = pkgs.docker_27;
      };
      # "https://github.com/viperML/dotfiles/blob/5002378af7d3e1f898b2eac9ff80ef9512d68587/modules/nixos/docker.nix" # L17
      # virtualisation.docker = {
      #   enable = true;
      #   enableOnBoot = true;
      #   extraOptions = "--registry-mirror=https://mirror.gcr.io --add-runtime crun=${pkgs.crun}/bin/crun --default-runtime=crun";
      #   enableNvidia =
      #     lib.mkIf
      #     (builtins.any (v: v == "nvidia") config.services.xserver.videoDrivers)
      #     true;
      # };
      # services.dockerRegistry.enable = true;
    }
    # "https://github.com/Kranzes/nix-config/blob/6ce722810d7f7ff773deb1b1f87a306f7aefd0e3/profiles/tailscale.nix" # L18
    (lib.optionalAttrs (options ? environment.persistence) {
      environment.persistence = {
        "/persist" = {
          directories = [ "/var/lib/docker" "/var/lib/containers" ];
        };
      };
    })
    (lib.mkIf cfg.nvidia.enable {
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      virtualisation.docker.daemon.settings.features.cdi = cfg.nvidia.enable;
      virtualisation.containers.cdi.dynamic.nvidia.enable = cfg.nvidia.enable;
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
