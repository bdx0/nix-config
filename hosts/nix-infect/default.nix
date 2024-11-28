{ pkgs, name, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/common.nix

  ];
  boot.loader.grub.device = "nodev";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.hostName = "nix-infect";
  networking.domain = "nix-infect.bdx0.io.vn";
  users.users.dd = { isNormalUser = true; };

  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = "figurine ${name}";
  environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
}
