{ inputs, pkgs, config, lib, ... }:
let
  cfg = config.bdx0.common;
  system = pkgs.system;
in {
  # _module.args.config.inputs = self.inputs;
  imports = [
    inputs.agenix.nixosModules.default
    # inputs.impermanence.nixosModules.impermanence
    ./options.nix
    ./base.nix
    ./docker.nix
    ./libvirtd.nix
    ./hardware.nix
    ./server.nix
    ./postgresql.nix
    ./pgbouncer.nix
    ./pgpool.nix
    ./repmgr.nix
    ./onedb.nix
    ./monit.nix
    ./network-recovery.nix
  ];
  options.bdx0.common = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.bdx0.services.postgresql.enable {
      age.secrets.repmgr_pass = {
        file = ../../secrets/repmgr_pass.age;
        owner = "postgres";
        group = "postgres";
      };
      age.secrets.repmgr_pub = {
        file = ../../secrets/repmgr_pub.age;
        mode = "644";
        owner = "postgres";
        group = "postgres";
        symlink = false;
        path = "${config.users.users.postgres.home}/.ssh/id_rsa.pub";
      };
      age.secrets.repmgr_prv = {
        file = ../../secrets/repmgr_prv.age;
        mode = "600";
        owner = "postgres";
        group = "postgres";
        symlink = false;
        path = "${config.users.users.postgres.home}/.ssh/id_rsa";
      };
      age.secrets.authorized = {
        file = ../../secrets/repmgr_pub.age;
        mode = "600";
        owner = "postgres";
        group = "postgres";
        symlink = false;
        path = "${config.users.users.postgres.home}/.ssh/authorized_keys";
      };
    })
    (lib.mkIf cfg.enable {
      bdx0.server.enable = true;
      age.secrets.pg_pass = { file = ../../secrets/pgadmin.age; };
      age.secrets.rke2_config = { file = ../../secrets/rke2_config.age; };
      age.secrets.lina01_rke2_config = {
        file = ../../secrets/lina01_rke2_config.age;
      };
      age.secrets.bobo01_rke2_config = {
        file = ../../secrets/bobo01_rke2_config.age;
      };
      age.secrets.goku01_rke2_config = {
        file = ../../secrets/goku01_rke2_config.age;
      };
      age.secrets.bobo_rke2_config = {
        file = ../../secrets/bobo_rke2_config.age;
      };
      age.secrets.dd_pass = { file = ../../secrets/dd_pass.age; };
      environment.systemPackages = with pkgs; [
        wget
        inputs.agenix.packages.${system}.default
        cmatrix
        parted
        comma
        bottom
        btop
        bridge-utils
        pciutils
        floorp
        # lsof
        # lshw
        # openiscsi
        atop
      ];
      time.timeZone = "Asia/Ho_Chi_Minh";
      console.keyMap = "us";
      console.font = "Lat2-Terminus16";
      i18n.defaultLocale = "en_US.UTF-8";

      # automatic upgrade
      # "https://discourse.nixos.org/t/deployment-tools-evaluating-nixops-deploy-rs-and-vanilla-nix-rebuild/36388/25"
      # "https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/2"
      # "https://github.com/reckenrode/nixos-configs"
      # "https://nixos.wiki/wiki/Automatic_system_upgrades"
      # "https://aires.fyi/blog/why-is-enabling-automatic-updates-in-nixos-hard/"
      # "https://github.com/henrydenhengst/mynixos/blob/4fe32e02afa8b42ed05a3f7b7e4de0222a3acaa5/configuration.nix"
      system.stateVersion = "24.11";
      # # System-wide settings
      # system.autoUpgrade.enable = true; # Enable automatic system upgrades
      # system.autoUpgrade.allowReboot = true;
      # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
      # flake = inputs.self.outPath;
      # flags = [
      #   "--update-input"
      #   "nixpkgs"
      #   "--no-write-lock-file"
      #   "-L" # print build logs
      # ];
      # dates = "02:00";
      # randomizedDelaySec = "45min";
      #  system.autoUpgrade.enable = true;
      #   system.autoUpgrade.dates  = "Fri *-*-1..7,15..21 01:00:00";
      #   system.autoUpgrade.flake  = "github:${config.userDefinedGlobalVariables.githubFlakeRepositoryName}#${config.userDefinedGlobalVariables.hostTag}";
      #   system.autoUpgrade.randomizedDelaySec = "5m";

      # Firmware updates - fwupd
      services.fwupd.enable = true;
      # Allow fwupd-refresh to restart if failed (after resume)
      systemd.services.fwupd-refresh = {
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "20";
        };
        unitConfig = {
          StartLimitIntervalSec = 100;
          StartLimitBurst = 5;
        };
      };

      # clean system
      # "https://nixos.wiki/wiki/Storage_optimization"
      nix = {
        package = pkgs.nixVersions.stable;
        settings.experimental-features = [ "nix-command" "flakes" ];
        settings.auto-optimise-store = true;
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
      };
      nix.settings.warn-dirty = false;
      nix.optimise.automatic = true;

      hardware.enableAllFirmware = true;

      services.postgresql.authentication = lib.mkForce ''
        #type database      DBuser origin-address auth-method
        local all           all                                trust
        # ipv4
        host  all           all     127.0.0.1/32               trust
        # host  all         repuser 127.0.0.1/32               trust
        # host  all         repuser 100.80.223.12/32           trust
        # repmgr
        local replication   repmgr                             trust
        host  replication   repmgr  127.0.0.1/32               trust
        host  replication   repmgr  100.79.175.84/32           trust
        host  replication   repmgr  100.80.223.12/32           trust
        host  replication   repmgr  192.168.0.0/16             trust
        local repmgr        repmgr                             trust
        host  repmgr        repmgr  127.0.0.1/32               trust
        host  repmgr        repmgr  100.79.175.84/32           trust
        host  repmgr        repmgr  100.80.223.12/32           trust
        host  repmgr        repmgr  192.168.0.0/16             trust

        host  all           postgres 100.113.208.51/32         trust
        host  all           postgres 100.126.131.77/32         trust
        host  all           postgres 100.80.223.12/32          trust
        host  all           postgres 100.79.175.84/32          trust
        host  all           postgres 100.106.121.43/32          trust
        # host  all           postgres 100.113.208.51/32         md5
        # host  all           postgres 100.79.175.84/32          md5
        host  all           repuser 100.126.131.77/32          trust
        host  all           repuser 100.106.121.43/32          trust


        # ipv6
        host  all           all     ::1/128                    trust
        local replication   repmgr                             trust
        host  replication   repmgr  ::1/128                    trust
        host  replication   repmgr  fe80::5054:ff:fe89:7db/128 trust
        host  replication   repmgr  fd7a:115c:a1e0::3401:df0e/128 trust
        host  replication   repmgr  fe80::5054:ff:fe52:76cf/128 trust
        host  replication   repmgr  fd7a:115c:a1e0::8701:af54/128 trust
        local repmgr        repmgr                             trust
        host  repmgr        repmgr  ::1/128                    trust
        host  repmgr        repmgr  fe80::5054:ff:fe89:7db/128 trust
        host  repmgr        repmgr  fd7a:115c:a1e0::3401:df0e/128 trust
        host  repmgr        repmgr  fe80::5054:ff:fe52:76cf/128 trust
        host  repmgr        repmgr  fd7a:115c:a1e0::8701:af54/128 trust

        # rke2 database
        # local rke2     rke2    127.0.0.1/32   trust
        # # pgadmin
        # local all      pgadmin peer
        # local all      rke2    peer
        # local all      all     trust

      '';
    })
  ];
}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
