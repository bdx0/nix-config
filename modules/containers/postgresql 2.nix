{ inputs, pkgs, config, lib, ... }:
let
  cfg = config.bdx0.containers.postgres;
  linuxPkgs = import inputs.nixpkgs {
    system = "x86_64-linux";
    config = pkgs.config;
  };

in {
  options.bdx0.containers.postgres = {
    enable = lib.mkEnableOption "Whether to enable the postgres container.";
  };
  config = lib.mkIf cfg.enable {
    # virtualisation.oci-containers.backend = "docker";
    # virtualisation.oci-containers.containers = {
    #   postgres = let
    #     images = import ./image_pulls.nix { inherit (pkgs) dockerTools; };
    #     postgres_config = pkgs.writeTextDir "etc/postgresql.conf" ''
    #       listen_addresses = '*'
    #       port = 5432
    #       max_connections = 100
    #       shared_buffers = 128MB
    #       dynamic_shared_memory_type = posix
    #       log_timezone = 'UTC'
    #       datestyle = 'iso, mdy'
    #       timezone = 'UTC'
    #       lc_messages = 'C'
    #       lc_monetary = 'C'
    #       lc_numeric = 'C'
    #       lc_time = 'C'
    #       default_text_search_config = 'pg_catalog.english'
    #     '';
    #     postgres = pkgs.dockerTools.buildImage {
    #       name = "postgres";
    #       tag = "latest";
    #       fromImage = images.postgres;
    #       # contents = [ postgres_config ];
    #       # config = {
    #       # Cmd = [ "postgres" ];
    #       # WorkingDir = "/data";
    #       # Volumes = { "/data" = { }; };
    #       # };
    #     };
    #   in {
    #     # image = "postgres:15.0";
    #     image = "${postgres.imageName}:${postgres.imageTag}";
    #     # imageStream = postgres;
    #     imageFile = postgres;
    #     # imageFile = images.postgres;
    #     ports = [ "5432:5432" ];
    #     environment = {
    #       POSTGRES_DB = "postgres";
    #       POSTGRES_USER = "postgres";
    #       POSTGRES_PASSWORD = "postgres";
    #       PGDATA = "/data";
    #     };
    #     # cmd = [ "config_file=/config/postgresql.conf" ];
    #     # cmd = [ "postgres" "-c" "config_file=/config/postgresql.conf" ];
    #     # cmd = [ "-c" "config_file=/config/postgresql.conf" ];
    #     # volumes = [
    #     #   "/tmp/postgres/data:/data"
    #     #   "/tmp/postgres/data:/config"
    #     #   "/tmp/postgres/archive:/mnt/server/archive"
    #     # ];
    #     extraOptions = [
    #       #  "--network=host"
    #       # "-c"
    #     ];
    #   };
    # };
  };
}
