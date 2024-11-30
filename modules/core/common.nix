{ name, pkgs, lib, ... }: {
  imports = [ ./docker.nix ];
  time.timeZone = "Asia/Ho_Chi_Minh";
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };
  system.stateVersion = "24.05";
  # System-wide settings
  system.autoUpgrade.enable = true; # Enable automatic system upgrades
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";

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
  networking.wireless.networks = {
    "GuaMupWifi" = { # SSID with no spaces or special characters
      psk = "0907650206"; # (password will be written to /nix/store!)
    };
  };
  networking.firewall.enable = false;

  nix = {
    package = pkgs.nixVersions.stable;
    settings.warn-dirty = false;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  # DEPLOYMENT
  deployment.targetHost = name;
  deployment = {
    targetUser = "root";
    buildOnTarget = true;
  };

  nixpkgs.config.allowUnfree = true;

}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
