{ inputs, config, pkgs, lib, name, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {

    boot.loader.grub.enable = true;
    boot.loader.systemd-boot.enable = false;
    # config with efiInstallAsRemovable = true
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.grub.devices = [ "/dev/sdf" ];
    # boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = false;
    # boot.supportedFilesystems = ["zfs"];
    boot.kernelModules =
      [ "overlay" "br_netfilter" "ip=dhcp" "kvm-intel" "wl" ];
    boot.initrd.availableKernelModules = [

      "sr_mod"
      "usbhid"
      "usb_storage"
      "ata_piix"
      "uhci_hcd"
      "xen_blkfront"
      "vmw_pvscsi"
      "ehci_pci"
      "ahci"
      "nvme"
      "xhci_pci"
      "sd_mod"

    ];

    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/da68fc10-e2ea-43c0-834a-2362d6d955a1";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/C68A-9456";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/run/media/Data3T" = {
      device = "/dev/disk/by-uuid/7fadc837-1530-482d-b4f8-09c1fd50419d";
      fsType = "ext4";
    };

    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = false;
    networking.domain = "bobo.bdx0.io.vn";
    bdx0.vfio.IOMMUType = "intel";
    bdx0.vfio.devices = [ "10de:21c4" "10de:1aeb" "10de:1aec" "10de:1aed" ];

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [ kubectl nvtopPackages.full ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
    };

    # services.xserver = { videoDrivers = [ "nvidia" ]; };
    # hardware.nvidia.open = true;
    # hardware.nvidia.modesetting.enable = true;
    # hardware.nvidia.powerManagement.enable = true;
    # hardware.nvidia.powerManagement.finegrained = true;
    # hardware.nvidia.nvidiaSettings = false;
    # hardware.nvidia-container-toolkit.enable = true;
    # hardware.graphics.enable = true;
  };
}
