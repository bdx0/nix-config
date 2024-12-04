{ modulesPath, lib, config, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  options.common = {
    base.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "This is the base";
    };
  };
  config = lib.mkIf config.common.base.enable {
    services.tailscale.enable = true;
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "yes";
    services.openssh.settings.PasswordAuthentication = true;
    services.openssh.settings.KbdInteractiveAuthentication = true;
    users.users.root.openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
    users.users.dd = {
      isNormalUser = true;
      home = "/home/dd";
      extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
      openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
    };
    security.sudo.wheelNeedsPassword = false;
    security.sudo.enable = true;
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

    networking.useDHCP = true;
    networking.wireless.enable = true;
    networking.wireless.networks = {
      "GuaMupWifi" = { # SSID with no spaces or special characters
        psk = "0907650206"; # (password will be written to /nix/store!)
      };
    };
    networking.firewall.enable = false;
  };
}
