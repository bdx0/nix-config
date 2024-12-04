{ ... }: {
  imports = [ ../common/microvm.nix ../core/colmena.nix ];
  config = { nixpkgs.config.allowUnfree = true; };
}
