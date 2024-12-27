{ inputs, ... }: {
  imports =
    [ inputs.self.nixosModules.common inputs.self.nixosModules.disko.btrfs ];
  config = {

    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.docker.enable = true;
    bdx0.docker.nvidia.enable = true;

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;
  };
}
