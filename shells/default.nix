{ pkgs ? import <nixpkgs> { }, ... }: {
  default = pkgs.mkShell {
    NIX_CONFIG = "experimental-features = nix-command flakes";
    buildInputs = with pkgs; [
      #
      lsd
      tig
      git
      neovim
      emacs
      gh
      nixfmt-classic
      nix
      home-manager
    ];
  };
}
