{ pkgs ? import <nixpkgs> {
  system = builtins.system;
  config.allowUnfree = true;
}, agenixPkg ? null, ... }:
let scripts_dir = import ../scripts { inherit pkgs; };
in {
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    buildInputs = with pkgs;
      [
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
        colmena
        comma
        just
        kubectl
        kubernetes-helm
        helmfile
        k9s
        nix-prefetch-docker
        virt-manager
      ] ++ (if agenixPkg != null then [ agenixPkg ] else [ ]);
    shellHook = ''
      source ${scripts_dir}/bin/bash_aliases
    '';
  };
}
