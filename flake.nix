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
    in flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      flake = { };
      systems = allSystems;
      perSystem = { pkgs, system, ... }: {
        devShells = import ./shells { inherit pkgs; };
        packages.formatDisk = nixpkgs.lib.mkDerivation { };
      };
    };

}
