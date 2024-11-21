{ modulesPath, pkgs, vscode-server, ssh-keys, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    vscode-server.nixosModules.default
    ./hardware-configuration.nix
    "${
      (builtins.fetchTarball {
        url = "https://github.com/numtide/nixos-facter-modules/";
      })
    }/modules/nixos/facter.nix"
  ];

  config.facter.reportPath = ./facter.json;
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  # boot.loader.grub = {
  #   # no need to set devices, disko will add all devices that have a EF02 partition to the list already
  #   # devices = [ ];
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  # };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.efi.canTouchEfiVariables = false;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.device = "nodev";
  # boot.loader.grub.efiInstallAsRemovable = true;

  networking.hostName = "freshHost";
  networking.useDHCP = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Easiest to use and most distros use this by default.
  # FIX: disable because conflict with networking.useDHCP = true
  # networking.networkmanager.enable = true;

  # Set your time
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    #useXkbConfig = true; # use xkb.options in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dd = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ neovim tree ];
    # Created using mkpasswd
    hashedPassword =
      "$y$j9T$vWaaHufiHK9z26Gq8Y2Hz0$1ec79eYer.N97S0nTZfMimfkrGCdPYBuWhIjWaSdW43";
    # openssh.authorizedKeys = let
    #   authorizedKeys = pkgs.fetchurl {
    #     url = "https://github.com/bdx0.keys";
    #     sha256 = "1kril7clfay225xdfhpp770gk60g5rp66nr6hzd5gpxvkynyxlrf";
    #   };
    # in pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
    openssh.authorizedKeys.keys =
      pkgs.lib.splitString "\n" (builtins.readFile ssh-keys.outPath);
  };

  # Environment packages
  environment.systemPackages = with pkgs; [
    curl
    wget
    neovim
    k3s
    cifs-utils
    nfs-utils
    git
    direnv
  ];

  # Enable service
  services.openssh.enable = true;
  networking.firewall.enable = false;
  # How to move this into a seperate file?
  services.vscode-server.enable = true;
  services.gitwatch.various-config = {
    enable = true;
    path = "/home/surt/syncthing/various-config/";
    remote = "git@github.com:borgstad/various-config.git";
    user = "surt";
  };

  system.stateVersion = "24.05";
}
