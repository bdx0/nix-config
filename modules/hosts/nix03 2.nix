{ inputs, ... }: {
  imports =
    [ inputs.self.nixosModules.common inputs.self.nixosModules.containers ];
  config = {
    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.container.engine = "docker";

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    bdx0.services.monit.enable = true;
    bdx0.services.monit.address = "100.80.223.12";

  };
}
