{ config, lib, ... }:
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
    virtualisation = {
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
    services.dockerRegistry.enable = true;
  };
}
