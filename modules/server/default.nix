{ ... }: {
  imports = [ ../common/microvm.nix ../core/hardware.nix ../core/colmena.nix ];
  config = { nixpkgs.config.allowUnfree = true; };
}
