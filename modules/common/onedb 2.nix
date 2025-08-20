{ config, lib, pkgs, ... }:
let cfg = config.bdx0.services.onedb;
in {
  imports = [ ./postgresql.nix ./repmgr.nix ./pgbouncer.nix ];
  options.bdx0.services.onedb = {
    enable = lib.mkEnableOption "Enable OneDB service";
  };

  config = lib.mkIf cfg.enable {
    # users.groups.keys.members = [ "postgres" ];
    services.postgresql.enable = cfg.enable;
    services.postgresql.enableTCPIP = true;
    services.postgresql.ensureDatabases = [ "repmgr" ];
    # "https://www.linkedin.com/pulse/postgresql-high-availability-automatic-failover-using-vanzuita/"

    # services.postgresql.dataDir = "/var/lib/postgresql/data";
    # "https://www.youtube.com/watch?v=m3Lz6B_T4L0&ab_channel=AkamaiDeveloper"
    services.postgresql.ensureUsers = [{
      name = "repmgr";
      ensureDBOwnership = true;
      ensureClauses = {
        createdb = true;
        createrole = true;
        login = true;
        replication = true;
        superuser = true;
      };
    }];
    services.postgresql.settings = {
      # listen_addresses = lib.mkForce "0.0.0.0";
      log_connections = true;
      port = 5432;
      # Connectivity
      max_connections = 2000;
      wal_level = "replica";
      archive_mode = "on";
      # archive_command =
      #   "test ! -f /var/lib/postgresql/replica_archive/%f && cp %p /var/lib/postgresql/replica_archive/%f";
      archive_command = "${pkgs.coreutils}/bin/true";
      max_wal_senders = 10;
      max_replication_slots = 10;
      hot_standby = "on";
      shared_preload_libraries = "repmgr";
      wal_log_hints = "on";
    };
    services.postgresql.initialScript = pkgs.writeText "init.sql" "";
    # "https://github.com/ibizaman/selfhostblocks/blob/539631ca4ca049a987cfe7c99569390ab571c1c4/modules/blocks/postgresql.nix" # L137
    # "https://github.com/NuschtOS/nixos-modules/blob/8a56b2b97d0e5858adab385f756e0c08ed593f03/modules/postgres.nix" # L236
    systemd.services.postgresql.postStart =
      let password_file_path = config.age.secrets.repmgr_pass.path;
      in ''
        $PSQL -tA <<'EOF'
          DO $$
          DECLARE password TEXT;
          BEGIN
            password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));
            EXECUTE format('ALTER USER repmgr WITH PASSWORD '''%s''';', password);
          END $$;
        EOF
      '';
    environment.etc."/repmgr.conf".text = ''
      node_id=1
      node_name='nix02'
      conninfo='host=100.79.175.84 user=repmgr dbname=repmgr connect_timeout=2'
      data_directory='${config.services.postgresql.dataDir}'
      failover=automatic
      promote_command='repmgr standby promote -f /etc/repmgr.conf --log-to-file'
      follow_command='repmgr standby follow -f /etc/repmgr.conf --log-to-file -W --upstream-node-id=%n'
      log_file='/var/log/repmgr/repmgr.log'
      repmgrd_service_start_command="repmgrd -f /etc/repmgr.conf --daemonize"
      repmgrd_service_stop_command="repmgrd -f /etc/repmgr.conf --daemonize=false"
      service_start_command="systemctl start postgresql"
      service_stop_command="systemctl stop postgresql"
      service_restart_command="systemctl restart postgresql"
      service_reload_command="systemctl reload postgresql"
    '';

    # environment.etc."/repmgr.conf".text = ''
    #   node_id=2
    #   node_name=nix03
    #   conninfo='host=100.80.223.12 user=repmgr dbname=repmgr connect_timeout=2'
    #   data_directory='${config.services.postgresql.dataDir}'
    #   failover=automatic
    #   promote_command='repmgr standby promote -f /etc/repmgr.conf --log-to-file'
    #   follow_command='repmgr standby follow -f /etc/repmgr.conf --log-to-file -W --upstream-node-id=%n'
    #   log_file='/var/log/repmgr/repmgr.log'
    #   repmgrd_service_start_command="repmgrd -f /etc/repmgr.conf --daemonize"
    #   repmgrd_service_stop_command="repmgrd -f /etc/repmgr.conf --daemonize=false"
    #   service_start_command="systemctl start postgresql"
    #   service_stop_command="systemctl stop postgresql"
    #   service_restart_command="systemctl restart postgresql"
    #   service_reload_command="systemctl reload postgresql"
    # '';

    # alter user repmgr with password '${config.age.secrets.repmgr_pass.content}';
    # CREATE USER repuser REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD '${config.age.secrets.repuser_pass.content}';
    # CREATE DATABASE repdb OWNER repuser;
    services.postgresql.extensions = ps: with ps; [ repmgr ];
  };
}
