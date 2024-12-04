{
  description = "Make flake for nix-config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixos.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hardware.url = "github:nixos/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    ssh-keys = {
      url = "https://github.com/bdx0.keys";
      flake = false;
    };
    nixvirt.url = "github:AshleyYakeley/NixVirt";
    microvm.url = "github:astro/microvm.nix";
  };
  outputs = { self, nixos, nixpkgs, flake-parts, ... }@inputs:
    let
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      allSystems = linuxSystems ++ darwinSystems;
    in flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      flake = {
        colmena = let
          pkgsLinux = import nixos { system = "x86_64-linux"; };
          pkgsLinuxArm = import nixos { system = "aarch64-linux"; };
        in {
          meta = {
            nixpkgs = pkgsLinux;
            nodeNixpkgs = {
              "nix-infect.local" = pkgsLinuxArm;
              lina = pkgsLinux;
            };
            specialArgs = (inputs // { inherit inputs; });
          };
          "nix-infect.local" = import ./hosts/nix-infect;
          "lina" = import ./hosts/lina;
          "mac2014" = import ./hosts/mac2014;
          "bobo" = import ./hosts/bobo;
        };
        nixosConfigurations.basic = nixpkgs.lib.nixosSystem {
          modules = [
            inputs.nixos-facter-modules.nixosModules.facter
            { config.facter.reportPath = ./facter.json; }
          ];
        };
        nixosConfigurations.remoteInstall = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/freshHost ];
        };
        nixosConfigurations.lina = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/lina ];
        };
        nixosConfigurations.test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            inputs.microvm.nixosModules.microvm
            self.nixosModules.common
            self.nixosModules.vm
            {
              networking.useNetworkd = true;
              networking.hostName = "test";
              users.users.root.password = "testtest";
              nixpkgs.config.allowUnfree = true;
            }
          ];
        };
      };
      systems = allSystems;
      perSystem = { system, pkgs, inputs', ... }@args: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        devShells = import ./shells { inherit pkgs; };
        packages = import ./pkgs args;

        # nix store repair:
        # nix-store --verify --repair --check-contents
      };
    } // {
      nixosModules = import ./modules/core;
    };
}
