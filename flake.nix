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
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
  };
  outputs = { self, nixos, nixpkgs, flake-parts, darwin, ... }@inputs:
    let
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      allSystems = linuxSystems ++ darwinSystems;
    in flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      flake = let
        nodes = [
          { name = "homelab-0"; }
          { name = "homelab-1"; }
          { name = "homelab-2"; }
          { name = "scratchHost"; }
        ];
      in {
        colmena = let
          pkgsLinux = import nixos {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          pkgsLinuxArm = import nixos {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
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
          "lina" = { imports = [ ./hosts/lina ]; };
          "mac2014" = import ./hosts/mac2014;
          "bobo" = import ./hosts/bobo;
          "goku" = import ./hosts/goku;
          "nix01" = import ./hosts/nix01;
          "nix02" = import ./hosts/nix02;
          "nix03" = import ./hosts/nix03;
          "cephgoku" = import ./hosts/cephgoku;
          "cephbobo" = import ./hosts/cephbobo;
          "cephlina" = import ./hosts/cephlina;
          "dev" = import ./hosts/dev;
        };
        nixosConfigurations = builtins.listToAttrs (map (node:
          let system = node.system or "x86_64-linux";
          in {
            name = node.name;
            value = nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = {
                inherit inputs;
                meta = {
                  hostname = node.name;
                  inherit system;
                };
              };
              modules = [
                self.nixosModules.hosts.${node.name}

              ];

            };
          }) nodes);

        darwinConfigurations = builtins.listToAttrs (map (node:
          let system = node.system or "aarch64-darwin";
          in {
            name = node.name;
            value = darwin.lib.darwinSystem {
              inherit system;
              specialArgs = {
                meta = {
                  hostname = node.name;
                  inherit system;
                };
              };
              modules = [

                self.nixosModules.hosts.${node.name}
              ];
            };
          }) nodes);

      };
      systems = allSystems;
      perSystem = { system, pkgs, inputs', ... }@args: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        devShells = import ./shells {
          inherit pkgs;
          agenixPkg = inputs.agenix.packages.${system}.default;
        };
        packages = import ./pkgs args;

        # nix store repair:
        # nix-store --verify --repair --check-contents
      };
    } // {
      nixosModules = import ./modules;
    };
}
