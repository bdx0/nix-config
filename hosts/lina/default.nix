{ pkgs, name, nodes, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/common.nix

  ];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # boot.loader.systemd-boot.enable = true;

  # config with efiInstallAsRemovable = true
  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
  boot.loader.grub.useOSProber = true;
  # boot.loader.grub.efiInstallAsRemovable = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "lina.bdx0.io.vn";

  users.defaultUserShell = pkgs.bash;
  environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
}
