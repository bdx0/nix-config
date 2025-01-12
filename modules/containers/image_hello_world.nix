{ nix2container, dockerTools, hello, buildEnv, bashInteractive, coreutils
, runtimeShell, ... }:
let
  images = import ./image_pulls.nix { inherit dockerTools; };
  # image = "docker.io/bitnami/postgresql-repmgr:15";

  bash = dockerTools.buildImage {
    name = "bash";
    tag = "latest";
    copyToRoot = buildEnv {
      name = "image-root";
      paths = [ bashInteractive coreutils hello ];
      pathsToLink = [ "/bin" ];
    };
  };
  # "https://discourse.nixos.org/t/use-nix-docker-for-development/18359/9"
  postgres = dockerTools.buildImage {
    name = "postgres-docker";
    tag = "latest";
    fromImage = images.postgres;
    fromImageName = null;
    fromImageTag = "latest";
    # contents = pkgs.postgres;
    runAsRoot = ''
      #!${runtimeShell}
      mkdir -p /data
    '';

    config = {
      Cmd = [ "postgres" ];
      WorkingDir = "/data";
      Volumes = { "/data" = { }; };
    };
  };
  hello_world_image = dockerTools.buildImage {
    name = "hello-world";
    tag = "latest";
    # fromImage = bash;

    copyToRoot = buildEnv {
      name = "image-root";
      paths = [ bashInteractive coreutils hello ];
      pathsToLink = [ "/bin" ];
    };
    config = {
      WorkingDir = "/app";
      # Entrypoint = [ "${coreutils}/bin/sleep" "3600" ];
      # Cmd = [ "${coreutils}/bin/sleep" "3600" ];
      Cmd = [ "${hello}/bin/hello" ];
    };
  };
  hello_base_image = dockerTools.buildImage {
    name = "hello-world";
    tag = "latest";
    fromImage = bash;

    config = {
      WorkingDir = "/app";
      Cmd = [ "${hello}/bin/hello" ];
    };
  };
  hello_sleep_image = dockerTools.buildImage {
    name = "hello-world";
    tag = "latest";
    fromImage = bash;

    config = {
      WorkingDir = "/app";
      Entrypoint = [ "${coreutils}/bin/sleep" "3600" ];
      # Cmd = [ "${hello}/bin/hello" ];
    };
  };
  hello_image = nix2container.buildImage {
    name = "hello";
    config = { entrypoint = [ "${hello}/bin/hello" ]; };
  };
  hello_ubuntu_image = dockerTools.buildImage {
    name = "hello-ubuntu";
    tag = "latest";
    fromImage = images.ubuntu;
    copyToRoot = buildEnv {
      name = "image-root";
      paths = [ bashInteractive coreutils hello ];
      pathsToLink = [ "/bin" ];
    };

    config = {
      WorkingDir = "/app";
      Entrypoint = [ "${coreutils}/bin/sleep" "3600" ];
      # Cmd = [ "${hello}/bin/hello" ];
    };
  };
in hello_ubuntu_image
