{
  description = "Make flake for nix-config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  outputs = { nixpkgs, flake-parts, ... }@inputs:
  let
    darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
    linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
    allSystems = linuxSystems ++ darwinSystems;
  in flake-parts.lib.mkFlake (inputs // {}) {
    debug = true;
    flake = {};
    systems = allSystems;
    perSystems = {pkgs, system, ... }: {
      devShells = {
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
      };
    };
  };
}
