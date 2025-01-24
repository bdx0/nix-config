{ inputs, config, ... }: {
  imports = [ inputs.self.nixosModules.common ];
  config = {

    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = false;

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.vfio.enable = true;
    bdx0.vfio.IOMMUType = "intel";
    bdx0.container.engine = "docker";

    nixpkgs.config.allowUnfree = true;

    boot.kernel.sysctl = {
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
    };

    services.rke2 = {
      enable = true;
      role = "server";
      configPath = config.age.secrets.lina01_rke2_config.path;
      debug = true;
    };

  };

}
