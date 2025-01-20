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
    # darwin.inputs.nixpkgs.follows = "nixpkgs";
    microvm.url = "github:astro/microvm.nix";
    agenix.url = "github:ryantm/agenix";
    sops-nix.url = "github:Mic92/sops-nix";
    impermanence.url = "github:nix-community/impermanence";
    nix2container.url = "github:nlewo/nix2container";
  };
  outputs = { self, nixpkgs, flake-parts, darwin, ... }@inputs:
    let
      darwinSystems = [ "aarch64-darwin" "x86_64-darwin" ];
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      allSystems = linuxSystems ++ darwinSystems;
    in flake-parts.lib.mkFlake { inherit inputs; } {
      debug = true;
      flake = let
        nodes = [
          { name = "bobo"; }
          { name = "bobo01"; }
          { name = "lina"; }
          { name = "lina01"; }
          { name = "mac2014"; }
          { name = "scratchHost"; }
          { name = "nix01"; }
          { name = "nix02"; }
          { name = "nix03"; }
          { name = "goku"; }
          { name = "goku01"; }
        ];
      in {
        colmena = let
          confs = self.nixosConfigurations;
          pkgsLinux = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          pkgsLinuxArm = import nixpkgs {
            system = "aarch64-linux";
            config.allowUnfree = true;
          };
        in {
          meta = {
            description = "Colmena";
            nixpkgs = pkgsLinux;
            nodeNixpkgs = {
              "nix-infect.local" = pkgsLinuxArm;
              lina = pkgsLinux;
            } // builtins.mapAttrs (name: value: value.pkgs) confs;
            # specialArgs = (inputs // { inherit inputs; });
            nodeSpecialArgs =
              builtins.mapAttrs (name: value: value._module.specialArgs) confs;
          };
          # "nix-infect.local" = import ./hosts/nix-infect;
          # "nix02" = { self, name, ... }: {
          #   imports = self.nixosConfigurations.${name}._module.args.modules ++ [
          #
          #     # self.nixosModules.colmena
          #     # self.nixosConfigurations.nix02
          #   ];
          # };
          # "cephgoku" = import ./hosts/cephgoku;
          # "cephbobo" = import ./hosts/cephbobo;
          # "cephlina" = import ./hosts/cephlina;
        } // builtins.mapAttrs (name: value: {
          imports = value._module.args.modules ++ [

            self.nixosModules.colmena
          ];
        }) confs;
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
