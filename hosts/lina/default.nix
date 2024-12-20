{ inputs, config, pkgs, lib, name, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {
    boot.kernelModules =
      [ "overlay" "br_netfilter" "ip=dhcp" "kvm-intel" "wl" ];
    boot.initrd.availableKernelModules = [

      "sr_mod"
      "usbhid"
      "nvme"
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/2BF7-EA6A";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/" = {
      device = "/dev/mapper/lina--vg-root";
      fsType = "ext4";
    };
    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.systemd-boot.enable = true;

    # config with efiInstallAsRemovable = true
    boot.loader.efi.canTouchEfiVariables = true;

    # boot.loader.grub.enable = true;
    # boot.loader.grub.version = 2;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
    # boot.loader.grub.device = "nodev";
    # boot.loader.grub.useOSProber = true;
    # boot.loader.grub.efiInstallAsRemovable = true;

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = false;
    networking.domain = "lina.bdx0.io.vn";
    bdx0.vfio.IOMMUType = "intel";
    # bdx0.vfio.devices = [ ];

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [ kubectl ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
    };
    # systemd.services.postgresql.postStart = pkgs.lib.mkAfter ''
    #   # $PSQL atticd_v2 -tAc 'GRANT ALL ON ALL TABLES IN SCHEMA public TO atticd' || true
    #   # $PSQL atticd_v2 -tAc 'GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO atticd' || true
    #   # $PSQL atticd_v2 -tAc 'ALTER DATABASE atticd_v2 OWNER TO atticd' || true
    #   # $PSQL atticd_v2 -tAc "ALTER USER atticd WITH PASSWORD 'password'" || true
    # '';
    services.pgadmin = let initialEmail = "admin@lina.bdx0.io.vn";
    in {
      inherit initialEmail;
      enable = true;
      settings = {
        "ALLOW_HOSTS" = [ "*" ];
        "DEFAULT_SERVER" = "0.0.0.0";
      };
      initialPasswordFile = config.age.secrets.pg_pass.path;
    };
    # users.users.pgadmin = { extraGroups = [ config.users.groups.keys.name ]; };
    systemd.services.pgadmin.serviceConfig.SupplimentaryGroups =
      [ config.users.groups.keys.name ];

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "rke2" "pgadmin" ];
      ensureUsers = [
        {
          name = "pgadmin";
          ensureDBOwnership = true;
          ensureClauses = {
            createdb = true;
            createrole = true;
            login = true;
            replication = false;
            superuser = false;
          };
        }
        {
          name = "rke2";
          ensureDBOwnership = true;
          ensureClauses = {
            createdb = true;
            createrole = true;
            login = true;
            replication = false;
            superuser = false;

          };
          # ensurePermissions = {
          #   # TODO: possibly should be hardened but requirements are undocumented :/
          #   "DATABASE carnapdb" = "ALL PRIVILEGES";
          # };
        }
      ];
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        #type database DBuser origin-address auth-method
        # pgadmin
        local all      pgadmin peer
        local all      rke2    peer
        local all      all     trust

        # ipv4
        host  all      all     127.0.0.1/32   trust
        # host  all      all      0.0.0.0/0 trust
        # ipv6
        host  all      all     ::1/128        trust

      '';
      # https://pgtune.leopard.in.ua/#/
      # https://pgconfigurator.cybertec.at/
      # https://github.com/NixOS/infra/blob/4b5dd4f974d3f707b64ad60793b8182e645631ed/build/haumea/postgresql.nix
      initialScript = pkgs.writeText "init-script.sql" ''
        CREATE ROLE rke2 with PASSWORD 'rke2' SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS LOGIN;
        CREATE ROLE pgadmin with PASSWORD 'pgadmin' SUPERUSER CREATEROLE CREATEDB REPLICATION BYPASSRLS LOGIN;
        CREATE DATABASE pgadmin;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO pgadmin;
        GRANT ALL PRIVILEGES ON DATABASE postgres TO pgadmin;
        GRANT ALL PRIVILEGES ON DATABASE pgadmin to pgadmin;
      '';

      settings = {
        listen_addresses = "*";
        log_connections = true;
        # Connectivity
        max_connections = 2000;
        superuser_reserved_connections = 3;

        # https://vadosware.io/post/everything-ive-seen-on-optimizing-postgres-on-zfs-on-linux/#zfs-related-tunables-on-the-postgres-side
        full_page_writes = "off";

        # Memory Settings
        shared_buffers = "32 GB";
        work_mem = "128 MB";
        maintenance_work_mem = "2 GB";
        huge_pages = "off";
        effective_cache_size = "64 GB";
        effective_io_concurrency =
          100; # concurrent IO only really activated if OS supports posix_fadvise function
        random_page_cost =
          1.25; # speed of random disk access relative to sequential access (1.0)

        # Monitoring
        shared_preload_libraries =
          "pg_stat_statements"; # per statement resource usage stats
        track_io_timing = "on"; # measure exact block IO times
        track_functions =
          "pl"; # track execution times of pl-language procedures if any

        # Replication
        wal_level = "replica"; # consider using at least "replica"
        max_wal_senders = 0;
        synchronous_commit = "on";

        # Checkpointing:
        checkpoint_timeout = "15 min";
        checkpoint_completion_target = 0.9;

        # 2x default, hint from service logs
        max_wal_size = "5 GB";
        min_wal_size = "1 GB";

        # WAL writing
        wal_compression = "on";
        wal_buffers =
          -1; # auto-tuned by Postgres till maximum of segment size (16MB by default)
        wal_writer_delay = "200ms";
        wal_writer_flush_after = "1MB";

        # Background writer
        bgwriter_delay = "200ms";
        bgwriter_lru_maxpages = 100;
        bgwriter_lru_multiplier = 2.0;
        bgwriter_flush_after = 0;

        # Parallel queries:
        max_worker_processes = 24;
        max_parallel_workers_per_gather = 12;
        max_parallel_maintenance_workers = 12;
        max_parallel_workers = 24;
        parallel_leader_participation = "on";

        # Advanced features
        enable_partitionwise_join = "on";
        enable_partitionwise_aggregate = "on";
        jit = "on";
        max_slot_wal_keep_size = "1000 MB";
        track_wal_io_timing = "on";
        maintenance_io_concurrency = 100;
        wal_recycle = "on";
      };
    };

    services.rke2 = {
      enable = true;
      role = "server";
      configPath = config.age.secrets.rke2_config.path;
      debug = true;
    };
  };
}
