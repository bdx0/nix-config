{ pkgs, authorized_keys, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/common.nix

  ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables =
    true; # config with efiInstallAsRemovable = true
  boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
  boot.loader.grub.useOSProber = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.hostName = "lina";
  networking.domain = "lina.bdx0.io.vn";
  users.users.dd = { isNormalUser = true; };

  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = ''figurine -F "3d.flf" nix-infect'';
  environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
}
