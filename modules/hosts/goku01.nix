{ inputs, config, ... }: {
  imports =
    [ inputs.self.nixosModules.common inputs.self.nixosModules.disko.btrfs ];
  config = {

    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.container.engine = "docker";

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    # bdx0.services.monit.enable = true;
    # bdx0.services.monit.address = "100.126.131.77";

    services.rke2 = {
      enable = true;
      role = "server";
      configPath = config.age.secrets.goku01_rke2_config.path;
      debug = true;
    };
    environment.etc."/fuse.conf".text = ''
      user_allow_other
      mount_max = 1000
    '';
  };
}
