{ ... }: {
  imports = [ ../common/microvm.nix ../core/hardware.nix ../core/colmena.nix ];
  config = {
    nixpkgs.config.allowUnfree = true;
    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "server";
  };
}
