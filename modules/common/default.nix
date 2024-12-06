{ pkgs, config, lib, ... }:
let cfg = config.bdx0.common;
in {
  # _module.args.config.inputs = self.inputs;
  imports = [ ./base.nix ./docker.nix ./libvirtd.nix ];
  options.bdx0.common = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      wget
      figurine
      cmatrix
      parted
      comma
      bottom
      btop
      bridge-utils
      qemu
      qemu_kvm
      libvirt
      OVMF
      pciutils
      floorp
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
    nix = {
      package = pkgs.nixVersions.stable;
      settings.warn-dirty = false;
      settings.experimental-features = [ "nix-command" "flakes" ];
      settings.auto-optimise-store = true;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
    };

    hardware.enableAllFirmware = true;
  };
}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
