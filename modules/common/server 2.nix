{ lib, config, ... }:
let cfg = config.bdx0.server;
in {
  imports = [ ./microvm.nix ./hardware.nix ];
  options.bdx0.server = {
    enable = lib.mkEnableOption "Enable server configuration";
  };
  config = lib.mkIf cfg.enable { nixpkgs.config.allowUnfree = true; };
}
