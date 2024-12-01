{ pkgs, name, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/common.nix

  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "mac2014";
  networking.domain = "mac2014.bdx0.io.vn";

  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = "figurine ${name}";
  environment.systemPackages = with pkgs; [
    wget
    figurine
    cmatrix
    tmux
    git
    tig
    lazydocker
    lazygit
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
}
