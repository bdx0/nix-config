{ pkgs, modulesPath, lib, config, ... }@args:
let
  hostname = (if (builtins.hasAttr "meta" args) then
    args.meta.hostname
  else if (builtins.hasAttr "name" args) then
    args.name
  else
    "unknown");
  networks = {
    # "GuaMupWifi" = { # SSID with no spaces or special characters
    #   psk = "0907650206"; # (password will be written to /nix/store!)
    #   # pskRaw =
    #   #   "d46b532dc7c2f3ba9e32d9a4a102c4a43f7c7a17de8fd64a22c259cc48eae110";
    # };
    "ipx0" = { # SSID with no spaces or special characters
      psk = "0907650206"; # (password will be written to /nix/store!)
      # pskRaw =
      #   "d46b532dc7c2f3ba9e32d9a4a102c4a43f7c7a17de8fd64a22c259cc48eae110";
    };
    "GuaMup" = { # SSID with no spaces or special characters
      psk = "0907650206"; # (password will be written to /nix/store!)
      # pskRaw =
      #   "d46b532dc7c2f3ba9e32d9a4a102c4a43f7c7a17de8fd64a22c259cc48eae110";
    };
    # "GMHub" = { # SSID with no spaces or special characters
    #   psk = "0907650206"; # (password will be written to /nix/store!)
    #   # pskRaw =
    #   #   "d46b532dc7c2f3ba9e32d9a4a102c4a43f7c7a17de8fd64a22c259cc48eae110";
    # };
  };

  scripts_dir = import ../../scripts { inherit pkgs; };
  cfg = config.bdx0.base;
in {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  options.bdx0.base = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "This is the base";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
    # programs.zsh.enable = true;
    # programs.zsh.enableAutosuggestions = true;
    # programs.zsh.enableCompletion = true;
    # programs.zsh.enableLsColors = true;
    # programs.zsh.interactiveShellInit =
    #   "${pkgs.figurine}/bin/figurine ${config.networking.domain}";
    users.defaultUserShell = pkgs.fish;
    programs.fish.interactiveShellInit =
      "${pkgs.figurine}/bin/figurine ${config.networking.domain}";
    networking.hostName = hostname;
    networking.domain = "${hostname}.bdx0.io.vn";

    environment.systemPackages = [
      scripts_dir
      pkgs.fishPlugins.z
      pkgs.fishPlugins.done
      pkgs.fishPlugins.gruvbox
      pkgs.fishPlugins.fzf-fish
      pkgs.fishPlugins.forgit
      pkgs.fishPlugins.grc
      pkgs.fishPlugins.hydro
      pkgs.fzf
      pkgs.grc
    ] ++ config.bdx0.${hostname}.environment.systemPackages;

    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "both";
    # systemd.services.tailscaled.after =
    #   [ "network-online.target" "systemd-resolved.service" ];
    # "https://www.reddit.com/r/NixOS/comments/14w1404/every_nixos_rebuild_creates_a_new_tailscale/"
    # "https://discourse.nixos.org/t/solved-possible-to-automatically-authenticate-tailscale-after-every-rebuild-reboot/14296"
    # "https://tailscale.com/blog/nixos-minecraft"
    # "https://xeiaso.net/blog/borg-backup-2021-01-09/"

    # systemd.tmpfiles.rules = [
    #   "L /var/lib/tailscale/tailscaled.state - - - - /persist/var/lib/tailscale/tailscaled.state"
    # ];
    services.openssh.enable = true;
    services.openssh.settings.PermitRootLogin = "yes";
    services.openssh.settings.PasswordAuthentication = true;
    services.openssh.settings.KbdInteractiveAuthentication = true;
    users.users.root.openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
    users.mutableUsers = false;
    users.users.dd = {
      isNormalUser = true;
      home = "/home/dd";
      extraGroups = [
        "dd"
        "wheel"
        "networkmanager"
        "docker"
        "libvirtd"
        "incus-admin"
        # "sambashare"
      ];
      openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
      packages = with pkgs; [ tree neovim ];
      hashedPasswordFile = config.age.secrets.dd_pass.path;
    };
    users.users.code = {
      isNormalUser = true;
      home = "/home/code";
      extraGroups =
        [ "wheel" "networkmanager" "docker" "libvirtd" "incus-admin" ];
      openssh.authorizedKeys.keys = import ../ssh/bdx0.keys.nix;
      packages = with pkgs; [ tree neovim ];
      hashedPasswordFile = config.age.secrets.dd_pass.path;
    };
    security.sudo.wheelNeedsPassword = false;
    security.sudo.enable = true;
    services.avahi.enable = true;
    # services.avahi.interfaces = privateZeroTierInterfaces; # ONLY BROADCAST ON VPN
    services.avahi.nssmdns4 = true;
    services.avahi.ipv6 = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;
    services.avahi.publish.addresses = true;
    services.avahi.publish.domain = true;
    services.avahi.publish.workstation = true; # ADDED TO DESKTOP MACHINES

    # configuration systemd.network for microvm
    # "https://github.com/astro/microvm.nix/blob/0ab757d2d3e3214b0034b00f9cc3dcdba0b8c563/examples/microvms-host.nix" # L131
    networking.useDHCP = true;
    systemd.network.wait-online.enable = false;

    # networking.dhcpcd.enable = false;
    networking.dhcpcd.denyInterfaces = [ "enp*" ];
    networking.wireless.enable = true;
    networking.wireless.iwd.enable = false;
    networking.wireless.iwd.settings.IPv4.Enabled = true;
    networking.wireless.iwd.settings.IPv6.Enabled = true;
    networking.wireless.iwd.settings.Settings.AutoConnect = true;
    networking.wireless.iwd.settings.General.UseDefaultInterface = true;

    networking.wireless.userControlled.enable = false;
    networking.wireless.networks = networks;
    networking.firewall.enable = false;
    systemd.network.enable = true;
    systemd.network.netdevs."10-microvm".netdevConfig = {
      Kind = "bridge";
      Name = "microvm";
    };
    systemd.network.networks."microvm-eth0" = {
      matchConfig.Name = "vm-*";
      # Attach to the bridge that was configured above
      networkConfig.Bridge = "microvm";
    };
    systemd.network.networks."40-wireless" = let
      networkConfig = {
        DHCP = "yes";
        DNSSEC = "yes";
        DNSOverTLS = "yes";
        IgnoreCarrierLoss = "3s";
        DNS = [ "1.1.1.1" "1.0.0.1" ];
      };
    in {
      # enable = true;
      # name = "wlp*";
      inherit networkConfig;
      # dhcpV4Config.RouteMetric = 2048;
      matchConfig.Name = "wlp*";
      # networkConfig.DHCP = "yes";
      # this port is always connected and not required to be onlein
      dhcpConfig.RouteMetric = 20;
      linkConfig.RequiredForOnline = "routable";
    };
    systemd.network.networks."10-microvm" = {
      matchConfig.Name = "microvm";
      # Hand out IP addresses to MicroVMs.
      # Use `networkctl status microvm` to see leases.
      networkConfig = {
        DHCPServer = true;
        IPv6SendRA = true;
      };
      addresses = [
        { addressConfig.Address = "10.0.0.1/24"; }
        { addressConfig.Address = "fd12:3456:789a::1/64"; }
      ];
      ipv6Prefixes = [{ ipv6PrefixConfig.Prefix = "fd12:3456:789a::/64"; }];
    };
    networking.resolvconf.enable = false;
    # "https://github.com/NixOS/nixpkgs/issues/114118"
    networking.resolvconf.dnsExtensionMechanism = false;
    services.resolved.enable = false;
    services.resolved.extraConfig = ''
      DNSStubListener=no
      DNSOverTLS=yes
      DNSOverHTTPS=no
      DNSSEC=allow-downgrade
    '';
    # services.resolved.dnsovertls = "true";
    # services.resolved.dnssec = "true";
    # services.resolved.domains = [
    #   # "bdx0.io"
    #   "."
    # ];
    # services.resolved.fallbackDns = [

    #   "100.100.100.100#tailscale dns"
    #   "8.8.8.8#eight.eight.eight.eight"
    #   "1.1.1.1#one.one.one.one"
    # ];
    networking.nameservers = [
      # "100.100.100.100#tailscale dns"
      "8.8.8.8#eight.eight.eight.eight"
      "1.1.1.1#one.one.one.one"
    ];
    networking.useNetworkd = false;
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      # Change this to the interface with upstream Internet access
      # externalInterface = "eno1";
      internalInterfaces = [ "microvm" ];
    };
    environment.etc = {
      "resolv.conf" = {
        source = lib.mkForce "/run/systemd/resolve/resolv.conf";
      };
    };

    # Fixes for longhorn
    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/"
      "L+ /usr/bin/nsenter - - - - /run/current-system/sw/bin/nsenter"
    ];

    # "https://discourse.nixos.org/t/how-setup-iscsi/42129/4"
    services.openiscsi = {
      enable = true;
      name = "iqn.2016-04.com.open-iscsi:${hostname}";
      extraConfig = ''
        node.startup=automatic
        node.session.auth.authmethod=None
      '';
    };

    virtualisation.docker.logDriver = "json-file";
    # microvm network configurations
    # "https://uint.one/posts/configuring-wireguard-using-systemd-networkd-on-nixos/"
    # "https://xeiaso.net/blog/paranoid-nixos-2021-07-18/"
    # "https://github.com/mogria/nixos-config/blob/33482ac91bbb502802160c47d2bf013841d6d222/services/dhcpd-raspi.nix" # L55
    # "https://github.com/danielfullmer/nixos-config/blob/bc461c66f15530187cb1d3481147dbe9b9321ab1/profiles/nextcloud.nix" # L12
    # "https://github.com/lf-/dotfiles/blob/9343e74e4aef02541c05d24e84d009e305452ce8/configs/nix/machines/voracle/default.nix" # L91
    # "https://github.com/garbas/dotfiles/blob/a7e59a190ca83f016adef9ae7b9abfc5822cbf0e/nixosConfigurations/profiles/wayland.nix" # L31
    # "https://github.com/auntieNeo/nixrc/blob/425c34dc60332945ecbedba832a99a0c8426ad09/machines/asbel.nix" # L54
    # "https://github.com/stanipintjuk/nixos-router/blob/f0fe4ef6a3fef15f592c753644b9fa54f59d6777/mkRouter.nix" # L21
    # "https://github.com/flyingcircusio/fc-nixos/blob/171192a6d5053c8ab8a34c2d319041d69ccd6b45/nixos/platform/firewall.nix" # L95
    # "https://github.com/dolphin-emu/sadm/blob/63e47c929cb98d0425236fa291f931c60e24a09b/machines/altair/hypervisor.nix" # L16
    # "https://github.com/robur-coop/albatross/blob/80d24b58ba0c8a1033c38d9913956a3c9d9b3381/packaging/nixos/albatross_service.nix" # L33
    # "https://github.com/Mic92/dotfiles/blob/44fd975e45010a21aa210f972a0af9928f27e60b/machines/modules/dnsmasq.nix" # L49
    # "https://astro.github.io/microvm.nix/advanced-network.html"
    # "https://astro.github.io/microvm.nix/simple-network.html"
  };
}
# https://www.jjpdev.com/posts/home-router-nixos/
# https://nixos.wiki/wiki/Netboot
