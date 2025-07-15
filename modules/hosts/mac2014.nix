{ inputs, lib, pkgs, config, ... }: {
  imports = [ inputs.self.nixosModules.common ];

  config = let
    ifaceServices =
      (inputs.self.nixosModules.lib.configForIfaces [ "enp2s0f0" "wlp3s0" ]
        pkgs);
  in {
    # boot.initrd.availableKernelModules = [
    #   "xhci_pci"
    #   "virtio_pci"
    #   "uhci_hcd"
    #   "ehci_pci"
    #   "ahci"
    #   "firewire_ohci"
    #   "usbhid"
    #   "usb_storage"
    #   "sd_mod"
    #   "sdhci_pci"
    # ];
    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = false;

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/8e7e9985-58f6-47ae-883d-5c7e6f49cfa4";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/70D6-1701";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    boot.kernelModules = [ "kvm-intel" "wl" "ip=dhcp" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
      # config.boot.kernelPackages.rtl8192eu
    ];

    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.systemd-boot.enable = true;

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.container.engine = "docker";

    programs.nix-ld.enable = true;

    # networking.hostName = "mac2014";
    # networking.domain = "mac2014.bdx0.io.vn";

    bdx0.mac2014.environment.systemPackages = with pkgs;
      lib.mkAfter [
        wget
        cmatrix
        tmux
        lazydocker
        exo

      ];

    # environment.systemPackages = with pkgs;
    #   [ wget figurine cmatrix tmux git tig lazydocker lazygit ]
    #   ++ config.bdx0.common.packages;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # Copy the NixOS configuration file and link it from the resulting system
    # (/run/current-system/configuration.nix). This is useful in case you
    # accidentally delete configuration.nix.
    # system.copySystemConfiguration = true;
    # _module.args.ifaces = [ "enp2s0f0" "wlp3s0" ];
    bdx0.services.network-recovery = {
      enable = true;
      # interfaces = [ "enp2s0f0" "wlp3s0" ];
      # ifaceServices =
      #   ((inputs.self.nixosModules.lib.configForIfaces [ "enp2s0f0" ]) pkgs);
    };

  } // ifaceServices;

}
