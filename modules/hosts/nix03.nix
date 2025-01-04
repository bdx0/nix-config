{ inputs, config, pkgs, lib, ... }: {
  imports = [ inputs.self.nixosModules.common ];
  config = {
    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
    # users.groups.keys.members = [ "postgres" ];
    services.postgresql.enable = true;
    services.postgresql.enableTCPIP = true;
    # services.postgresql.ensureDatabases = [ "repmgr" ];
    # "https://www.linkedin.com/pulse/postgresql-high-availability-automatic-failover-using-vanzuita/"

    # users.users.postgres.home =
    #   lib.mkForce "${config.services.postgresql.dataDir}/..";
    # services.postgresql.dataDir = "/var/lib/postgresql/data";
    # services.postgresql.ensureUsers = [{
    #   name = "repmgr";
    #   ensureDBOwnership = true;
    #   ensureClauses = {
    #     createdb = true;
    #     createrole = true;
    #     login = true;
    #     replication = true;
    #     superuser = true;
    #   };
    # }];
    # services.postgresql.authentication = lib.mkOverride 10 ''
    #   #type database DBuser origin-address auth-method
    #   local all      all     trust
    #   # ipv4
    #   host  all      all     127.0.0.1/32   trust
    #   # host  all      repuser 127.0.0.1/32   trust
    #   # host  all      repuser 100.80.223.12/32   trust
    #   # repmgr
    #   local replication   repmgr                    trust
    #   host  replication   repmgr 127.0.0.1/32       trust
    #   host  replication   repmgr 100.79.175.84/32   trust
    #   host  replication   repmgr 100.80.223.12/32   trust
    #   host  replication   repmgr 192.168.0.0/16     trust
    #   local repmgr        repmgr                    trust
    #   host  repmgr        repmgr 127.0.0.1/32       trust
    #   host  repmgr        repmgr 100.79.175.84/32   trust
    #   host  repmgr        repmgr 100.80.223.12/32   trust
    #   host  repmgr        repmgr 192.168.0.0/16     trust

    #   # ipv6
    #   host all       all     ::1/128        trust
    # '';
    services.postgresql.settings = {
      #   listen_addresses = lib.mkForce "0.0.0.0";
      log_connections = true;
      #   port = 5432;
      #   # Connectivity
      max_connections = 2000;
      #   wal_level = "replica";
      #   archive_mode = "on";
      #   # archive_command =
      #   #   "test ! -f /var/lib/postgresql/replica_archive/%f && cp %p /var/lib/postgresql/replica_archive/%f";
      #   archive_command = "${pkgs.coreutils}/bin/true";
      #   max_wal_senders = 10;
      #   max_replication_slots = 10;
      hot_standby = "on";
      shared_preload_libraries = "repmgr";
      wal_log_hints = "on";
    };
    services.postgresql.initialScript = pkgs.writeText "init.sql" "";
    # systemd.services.postgresql.postStart =
    #   let password_file_path = config.age.secrets.repmgr_pass.path;
    #   in ''
    #     $PSQL -tA <<EOF
    #       DO %%
    #       DECLARE password TEXT;
    #       BEGIN
    #         password := trim(both from replace(pg_read_file('${password_file_path}'), E'\n', '''));
    #         EXECUTE format('ALTER USER repmgr WITH PASSWORD '''%s''';', password);
    #       END $$;
    #     EOF
    #   '';
    environment.etc."/repmgr.conf".text = ''
      node_id=2
      node_name=nix03
      conninfo='host=100.80.223.12 user=repmgr dbname=repmgr connect_timeout=2'
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

    # alter user repmgr with password '${config.age.secrets.repmgr_pass.content}';
    # CREATE USER repuser REPLICATION LOGIN CONNECTION LIMIT 1 ENCRYPTED PASSWORD '${config.age.secrets.repuser_pass.content}';
    # CREATE DATABASE repdb OWNER repuser;
    services.postgresql.extensions = ps: with ps; [ repmgr ];
    services.monit.enable = true;
    # "https://blog.vinahost.vn/cai-dat-cau-hinh-monit/"
    # "https://viblo.asia/p/gioi-thieu-ve-monit-cong-cu-giam-sat-server-manh-me-gAm5ybDXKdb"
    services.monit.config = ''
      set daemon 120
      set log /var/log/monit/monit.log
      set httpd port 2812 and
        use address 100.80.223.12
        allow 100.106.121.43
        allow dd
    '';
  };
}
