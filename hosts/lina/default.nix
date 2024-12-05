{ inputs, config, pkgs, lib, name, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {
    boot.initrd.availableKernelModules =
      [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "nvme" "usb_storage" ];

    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      #  ''vfio-pci.ids=""''
    ];
    boot.kernelModules = [ "kvm-intel" "vfio-pci" ];
    boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
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
    swapDevices = [ ];
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
    common.dvm.enable = true;

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    environment.systemPackages = with pkgs; [ wget figurine cmatrix comma ];
    nixpkgs.config.allowUnfree = true;

    # configuration systemd.network for microvm
    # "https://github.com/astro/microvm.nix/blob/0ab757d2d3e3214b0034b00f9cc3dcdba0b8c563/examples/microvms-host.nix" # L131
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
    services.resolved.enable = true;
    networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
    networking.useNetworkd = true;
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      # Change this to the interface with upstream Internet access
      # externalInterface = "eno1";
      internalInterfaces = [ "microvm" ];
    };
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
