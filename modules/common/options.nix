{ pkgs, lib, config, ... }: {
  options.bdx0.nix01.environment.systemPackages = lib.mkOption {
    description = "nix01's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.nix02.environment.systemPackages = lib.mkOption {
    description = "nix02's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.nix03.environment.systemPackages = lib.mkOption {
    description = "nix03's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.nix01.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.nix02.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.nix03.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.environment.systemPackages = lib.mkOption {
    description = "packages to install";
    type = lib.types.listOf lib.types.package;
    default = with pkgs; [
      lsd
      tig
      git
      neovim
      emacs
      gh
      nixfmt-classic
      nix
      git-crypt
      nixos-rebuild
      age
      colmena
      comma
      just
      kubectl
      kubernetes-helm
      helmfile
      k9s
      nixd
    ];
  };
  options.bdx0.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.string;
    default = [
      "ehci_pci"
      "ohci_pci"
      "ehci_hcd"
      "uhci_hcd"
      "ohci_hcd"
      "ahci"
      "usb_storage"
      "usbcore"
      "sd_mod"
      "sr_mod"
      "scsi_mod"
      "usbhid"
      "uas"
      "vmw_pvscsi"
      "xen_blkfront"
      "ata_piix"
      "virtio_blk"
      "virtio_pci"
      "xhci_pci"
      "nvme"
    ];
  };
  config = {
    bdx0.nix01.environment.systemPackages =
      config.bdx0.environment.systemPackages ++ (with pkgs; [
        lsd
        tig
        git
        neovim
        emacs
        gh
        nixfmt-classic
        nix
        git-crypt
        nixos-rebuild
        age
        colmena
        comma
        just
        kubectl
        kubernetes-helm
        helmfile
        k9s
        nixd
      ]);
    bdx0.nix02.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.nix03.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.nix01.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.nix02.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.nix03.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
  };
}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
