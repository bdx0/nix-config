{
  homelab-0 = import ./homelab.nix;
  homelab-1 = import ./homelab.nix;
  homelab-2 = import ./homelab.nix;
  basic = { inputs, ... }: {
    imports = [
      inputs.nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./facter.json; }
    ];
  };
  scratchHost = { inputs, ... }: {
    imports = [
      inputs.self.nixosModules.disko.btrfs
      inputs.self.nixosModules.common
      inputs.self.nixosModules.server
    ];
    config = {
      bdx0.disko.enable = true;
      networking.hostName = "scratchHost";
      networking.domain = "scratchHost.bdx0.io.vn";
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      hardware.nvidia.open = true;
    };
  };
  dev = { inputs, config, pkgs, lib, ... }: {
    imports = [
      inputs.self.nixosModules.common
      inputs.self.nixosModules.disko.btrfs
      inputs.self.nixosModules.server
    ];
    config = {
      boot.loader.grub.device = "/dev/vda";
      boot.kernelModules =
        [ "overlay" "br_netfilter" "ip=dhcp" "kvm-intel" "wl" ];
      boot.initrd.availableKernelModules = [
        "virtio_blk"
        "virtio_pci"
        "sr_mod"
        "nvme"
        "xhci_pci"
        "ehci_pci"
        "ohci_pci"
        "ehci_hcd"
        "uhci_hcd"
        "ohci_hcd"
        "ahci"
        "usb_storage"
        "usbcore"
        "sd_mod"
        "scsi_mod"
        "usbhid"
        "uas"
        "vmw_pvscsi"
        "xen_blkfront"
        "ata_piix"
      ];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/525e3a71-757e-49ab-b271-e47a73ce9641";
        fsType = "ext4";
        # options = [ "nouuid" ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/F640-FAAE";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

      hardware.cpu.intel.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;

      networking.domain = "dev.bdx0.io.vn";
      bdx0.vfio.enable = false;
      bdx0.libvirtd.enable = false;

      users.defaultUserShell = pkgs.bash;
      programs.bash.interactiveShellInit =
        "figurine ${config.networking.domain}";
      nixpkgs.config.allowUnfree = true;

      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      hardware.nvidia.open = true;
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.powerManagement.enable = true;
      # hardware.nvidia.powerManagement.finegrained = true;
      hardware.nvidia.nvidiaSettings = false;
      hardware.nvidia-container-toolkit.enable = true;
      hardware.graphics.enable = true;
      programs.nix-ld.enable = true;
      environment.systemPackages = with pkgs; [
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
  };

  lina = { inputs, ... }: {
    imports = [
      inputs.self.nixosModules.common

      inputs.self.nixosModules.server
    ];
  };
  test = { inputs, lib, ... }: {
    imports = [
      inputs.microvm.nixosModules.microvm
      inputs.self.nixosModules.common
      inputs.self.nixosModules.vm
      {
        imports = [ inputs.rke2.nixosModules.default ];
        microvm = {
          # ...add additional MicroVM configuration here
          interfaces = [{
            # type = "user";
            type = "tap";
            id = "vm-test";
            mac = "02:00:00:00:00:01";
          }];
        };

        # Don't interfere with k8s
        networking.firewall.enable = lib.mkForce false;

        services.rke2 = {
          enable = true;
          role = "server";
          extraFlags = [ "--disable" "rke2-ingress-nginx" ];
          # settings.kube-apiserver-arg = [ "anonymous-auth=false" ];
          # settings.tls-san = [ "<TODO>" ];
          # settings.write-kubeconfig-mode = "0644";
        };

        networking.useNetworkd = true;
        networking.hostName = "test";
        users.users.root.password = "testtest";
        nixpkgs.config.allowUnfree = true;
      }
    ];
  };
}
