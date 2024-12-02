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
  outputs = { nixos, nixpkgs, flake-parts, ... }@inputs:
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
            {
              config.facter.reportPath = ./facter.json;
            }
            # ...
          ];
        };
        nixosConfigurations.remoteInstall = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = (inputs // {
            inherit inputs;
            disks = [ "/dev/sda" ];
          });
          modules = [
            #
            ./hosts/freshHost
          ];
        };
        nixosConfigurations.lina = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = (inputs // {
            inherit inputs;
            disks = [ "/dev/sda" ];
          });
          modules = [
            #
            ./hosts/lina
          ];
        };
      };
      systems = allSystems;
      perSystem = { system, pkgs, inputs', ... }:
        let
          nixos-aw = inputs'.nixos-anywhere;
          nixos-aw-pkg = nixos-aw.packages.default;
          inherit (pkgs)
            runCommand writeShellScriptBin writeScriptBin symlinkJoin writeText;
          sshScript = writeShellScriptBin "ssh" ''
            echo "ssh call"
            echo "$@"
            ${pkgs.openssh}/bin/ssh -F${sshConfig} $@
          '';
          sshpassScript = writeShellScriptBin "sshpass" ''
            echo "sshpass: $@"
            ${pkgs.openssh}/bin/sshpass $@
          '';
          sshcopyidScript = writeShellScriptBin "ssh-copy-id" ''
            echo "ssh-copy-id: $@"
            ${pkgs.openssh}/bin/ssh-copy-id $@
            echo $@
          '';
          sshConfig = writeText "ssh_config" ''
            Host freshHost
              HostName 192.168.110.4
              User root

            Host *
              LogLevel INFO

          '';
          freshInstallScript = writeShellScriptBin "freshInstallScript" ''
            echo "$@"
            # ls -la ${nixos-aw-pkg}/libexec/nixos-anywhere
            # ${nixos-aw-pkg}/libexec/nixos-anywhere/nixos-anywhere.sh --flake .#remoteInstall --build-on-remote "$@"
            ${nixos-aw-pkg}/bin/nixos-anywhere --flake .#remoteInstall --build-on-remote "$@"
          '';
          runtimeDeps =
            # [ freshInstallScript sshScript sshpassScript sshcopyidScript ];
            # [ freshInstallScript sshScript ];
            [ freshInstallScript ];
        in {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          devShells = import ./shells { inherit pkgs; };
          packages.remoteInstall = symlinkJoin {
            # "https://ertt.ca/nix/shell-scripts/"
            name = freshInstallScript.name;
            paths = runtimeDeps;
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/${freshInstallScript.name} \
                            --prefix PATH : ${
                              pkgs.lib.makeBinPath runtimeDeps
                            } \
                            --suffix PATH : $out/bin'';
          };
          packages.test = writeShellScriptBin "test" ''
            echo $@
          '';
          packages.repair = writeShellScriptBin "repair" ''
            echo $@
            nix-store --verify --repair --check-contents
          '';
          packages.default = pkgs.hello-unfree;

          # nix store repair:
          # nix-store --verify --repair --check-contents
        };
    };
}
