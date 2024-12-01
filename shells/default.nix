{ pkgs ? import <nixpkgs> { }, ... }:
let scripts_dir = import ../scripts { inherit pkgs; };
in {
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    buildInputs = with pkgs; [
      #
      scripts_dir
      lsd
      tig
      git
      neovim
      emacs
      gh
      nixfmt-classic
      nix
      git-crypt
      nixos-rebuild
      age
      ssh-to-age
      colmena
      comma
      just
    ];
    shellHook = ''
      source ${scripts_dir}/bin/bash_aliases
    '';
  };
}
