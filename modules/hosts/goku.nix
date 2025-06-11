{ inputs, config, ... }: {
  imports = [ inputs.self.nixosModules.common ];
  config = {

    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.systemd-boot.enable = false;
    # config with efiInstallAsRemovable = true
    boot.loader.efi.canTouchEfiVariables = true;
    # boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.grub.devices = [ "/dev/nvme0n1" ];
    # boot.loader.grub.device = "nodev";
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = false;
    # boot.supportedFilesystems = ["zfs"];
    boot.kernelModules = [ "kvm-intel" "wl" "ip=dhcp" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.extraModulePackages = [
      config.boot.kernelPackages.broadcom_sta
      config.boot.kernelPackages.rtl8192eu
    ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/da68fc10-e2ea-43c0-834a-2362d6d955a1";
      fsType = "ext4"; # chuyển qua dùng btrfs
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

    fileSystems."/run/media/DATA3T2" = {
      device = "/dev/disk/by-uuid/fd6316af-9ef1-4be6-90b5-756756f2d871";
      fsType = "ext4";
    };

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = true;
    zramSwap.memoryPercent = 50;

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.libvirtd.enable = true;
    bdx0.vfio.enable = true;
    bdx0.vfio.IOMMUType = "intel";
    bdx0.vfio.devices = [ "10de:21c4" "10de:1aeb" "10de:1aec" "10de:1aed" ];

    nixpkgs.config.allowUnfree = true;
    # environment.systemPackages = with pkgs; [ kubectl nvtopPackages.full ];

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = "1";
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
