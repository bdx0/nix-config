{ config, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.initrd.availableKernelModules = [
    "r8169"
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "ip=dhcp" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  # boot.systemd.users.root.shell = "/bin/cryptsetup-askpass";
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.port = 22;
  boot.initrd.network.ssh.authorizedKeys =
    import ../../modules/ssh/bdx0.keys.nix;
  # pkgs.lib.splitString "\n" (builtins.readFile ssh-keys.outPath);
  boot.initrd.network.ssh.hostKeys = [ ./ssh_host_rsa_key ];

}
