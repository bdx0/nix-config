{ name, pkgs, lib, ... }: {
  imports = [ ./docker.nix ];
  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = true;
  users.users.root.openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
  users.users.dd = {
    isNormalUser = true;
    home = "/home/dd";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
  };
  security.sudo.wheelNeedsPassword = false;
  services.avahi.enable = true;
  # services.avahi.interfaces = privateZeroTierInterfaces; # ONLY BROADCAST ON VPN
  services.avahi.ipv6 = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.publish.addresses = true;
  services.avahi.publish.domain = true;
  services.avahi.nssmdns4 = true;
  services.avahi.publish.workstation = true; # ADDED TO DESKTOP MACHINES
  services.tailscale.useRoutingFeatures = "server";

  networking.hostName = lib.mkDefault name;
  networking.useDHCP = true;
  networking.wireless.enable = true;
  networking.wireless.networks = {
    "GuaMupWifi" = { # SSID with no spaces or special characters
      psk = "0907650206"; # (password will be written to /nix/store!)
    };
  };
  networking.firewall.enable = false;

  # automatic upgrade
  # "https://discourse.nixos.org/t/deployment-tools-evaluating-nixops-deploy-rs-and-vanilla-nix-rebuild/36388/25"
  # "https://discourse.nixos.org/t/best-practices-for-auto-upgrades-of-flake-enabled-nixos-systems/31255/2"
  # "https://github.com/reckenrode/nixos-configs"
  # "https://nixos.wiki/wiki/Automatic_system_upgrades"
  # "https://aires.fyi/blog/why-is-enabling-automatic-updates-in-nixos-hard/"
  # "https://github.com/henrydenhengst/mynixos/blob/4fe32e02afa8b42ed05a3f7b7e4de0222a3acaa5/configuration.nix"
  system.stateVersion = "24.05";
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

  # DEPLOYMENT
  deployment.targetHost = name;
  deployment = {
    targetUser = "root";
    buildOnTarget = true;
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
