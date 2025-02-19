{ pkgs, lib, config, ... }: {
  options.bdx0.goku.environment.systemPackages = lib.mkOption {
    description = "goku's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.goku01.environment.systemPackages = lib.mkOption {
    description = "goku01's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.goku02.environment.systemPackages = lib.mkOption {
    description = "goku02's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.lina.environment.systemPackages = lib.mkOption {
    description = "nix01's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.lina01.environment.systemPackages = lib.mkOption {
    description = "lina01 's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.bobo.environment.systemPackages = lib.mkOption {
    description = "nix01's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
  options.bdx0.bobo01.environment.systemPackages = lib.mkOption {
    description = "bobo01's system packages";
    type = lib.types.listOf lib.types.package;
    default = [ ];
  };
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
  options.bdx0.bobo.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.bobo01.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.lina.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.lina01.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.goku.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.goku01.initrd.availableKernelModules = lib.mkOption {
    description = "List of kernel modules to include in the initrd";
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  options.bdx0.goku02.initrd.availableKernelModules = lib.mkOption {
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
      pstree
      tree
      skopeo
      buildah
      nix-prefetch-docker
      dive
      openiscsi
      lsof
      lshw
      cloud-utils
      tmux
      seaweedfs
      # # "https://discourse.nixos.org/t/pull-docker-image-for-later-use/52106/6"
      # (pkgs.writeShellScriptBin "preload-images" ''
      #   # nix run nixpkgs#nix-prefetch-docker -- --image-name debian --image-tag buster
      #   docker load -i ${
      #     pkgs.dockerTools.pullImage {
      #       imageName = "debian";
      #       imageDigest =
      #         "sha256:58ce6f1271ae1c8a2006ff7d3e54e9874d839f573d8009c20154ad0f2fb0a225";
      #       sha256 = "1gybjys977mr4108bzkwhfb03qrrl6fxgr6jy67k3p1bx7s4jxwf";
      #       finalImageName = "debian";
      #       finalImageTag = "buster";
      #     }
      #   }
      # '')
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
      "iscsi_tcp"
    ];
  };
  config = {
    bdx0.nix01.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.nix02.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.nix03.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.goku.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.goku01.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.goku02.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.lina.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.lina01.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.bobo.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.bobo01.environment.systemPackages =
      config.bdx0.environment.systemPackages;
    bdx0.nix01.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.nix02.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.nix03.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.goku.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.goku01.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.goku02.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.lina.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.lina01.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.bobo.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
    bdx0.bobo01.initrd.availableKernelModules =
      config.bdx0.initrd.availableKernelModules;
  };
}

# "https://gist.github.com/YellowOnion/362cb30dfe895819f06b8d19e5ba5f07"
