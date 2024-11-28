{ name, pkgs, ... }: {
  imports = [ ./docker.nix ];
  time.timeZone = "Asia/Ho_Chi_Minh";
  system.stateVersion = "24.05";
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = true;
  services.avahi.enable = true;
  # services.avahi.interfaces = privateZeroTierInterfaces; # ONLY BROADCAST ON VPN
  services.avahi.ipv6 = true;
  services.avahi.publish.enable = true;
  services.avahi.publish.userServices = true;
  services.avahi.publish.addresses = true;
  services.avahi.publish.domain = true;
  services.avahi.nssmdns = true;
  services.avahi.publish.workstation = true; # ADDED TO DESKTOP MACHINES
  services.tailscale.useRoutingFeatures = "server";
  nix = {
    package = pkgs.nixVersions.stable;
    warn-dirty = false;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # DEPLOYMENT
  deployment.targetHost = name;
  deployment = {
    targetUser = "root";
    buildOnTarget = true;
  };

}
