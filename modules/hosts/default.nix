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
    imports =
      [ inputs.self.nixosModules.disko.btrfs inputs.self.nixosModules.common ];

    config = {
      bdx0.disko.enable = true;
      networking.hostName = "scratchHost";
      networking.domain = "scratchHost.bdx0.io.vn";
      services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
      hardware.nvidia.open = true;

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "virtio_pci"
        "ehci_pci"
        "uhci_hcd"
        "ahci"
        "usbhid"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
        "virtio_blk"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "ip=dhcp" ];
    };
  };

  dev = import ./dev.nix;
  bobo = import ./bobo.nix;
  mac2014 = import ./mac2014.nix;
  goku = import ./goku.nix;
  lina = import ./lina.nix;
  nix01 = import ./nix01.nix;
  nix02 = import ./nix02.nix;
  nix03 = import ./nix03.nix;
  test = { inputs, lib, ... }: {
    imports = [
      inputs.microvm.nixosModules.microvm
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
