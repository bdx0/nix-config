{ inputs, config, ... }: {
  imports = [ inputs.self.nixosModules.common ];
  config = {

    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "amd";
    # bdx0.libvirtd.enable = true;
    # bdx0.vfio.devices = [ "10de:1402" "10de:0fba" ];
    bdx0.vfio.IOMMUType = "amd";
    bdx0.vfio.enable = true;
    bdx0.container.engine = "docker";
    # bdx0.container.nvidia.enable = true;
    # boot.kernelModules = [ "ip=dhcp" "kvm-amd" "wl" ];
    # boot.initrd.availableKernelModules = [ ]
    #   ++ config.bdx0.common.initrd.availableKernelModules;

    nixpkgs.config.allowUnfree = true;

    services.rke2 = {
      enable = false;
      role = "server";
      configPath = config.age.secrets.bobo_rke2_config.path;
      debug = true;
    };
  };
}
