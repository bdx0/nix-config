{ inputs, pkgs, config, lib, ... }:
let
  cfg = config.bdx0.containers.hello_world;
  linuxPkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = pkgs.config;
  };

in {
  options.bdx0.containers.hello_world = {
    enable = lib.mkEnableOption "Whether to enable the hello_world container.";
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      hello_world = let
        image_hello_world = pkgs.callPackage ./image_hello_world.nix {
          nix2container =
            inputs.nix2container.packages.${pkgs.system}.nix2container;
          dockerTools = pkgs.dockerTools;
          hello = linuxPkgs.hello;
          buildEnv = linuxPkgs.buildEnv;
          bashInteractive = linuxPkgs.bashInteractive;
          coreutils = linuxPkgs.coreutils;
          runtimeShell = linuxPkgs.runtimeShell;
        };
      in {
        image = "${image_hello_world.imageName}:${image_hello_world.imageTag}";
        imageFile = (builtins.trace (builtins.toString image_hello_world)
          image_hello_world);
        ports = [ "8000:80" ];
      };
    };
  };
}
