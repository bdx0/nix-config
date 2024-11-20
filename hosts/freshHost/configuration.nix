{ modulesPath, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware-configuration.nix
  ];
  nix = {
    package = pkgs.nixFlakes;
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
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiuM0LPeQ/A+R1zBTsMOlEyLl7KjeSFVXFpn9cqHll3yJRwo+f7s8foROFyj6qZJNAljCz6PoQrVaiTOsafKOlvKw4THCss9sikDFWN24XZ99FjljNW1rPMyhsdOjArxkT4OUyakytVMlMNMZOAG0zg8ZP1qYXR2UJhDUxJDsd/oCG5TxFVosBm+eKUDty9yfeIh7FrsO0c73jVVb8TkicXdpZTifebYCd3NQBmaP5JDmhA4wTMVfXKHC/8radKWAcZBWt+68zzRwDJH6/BLN6s3y3WygJ6X1XNSBMDDSo6YPY8erqNQ2Klvd3lTDC8IG9thvdZVAQqx7yYt8geERzwfPki6e8lMFnykd0mWXqSRirkkW31LyZ4DgWBQ/BIDuqzdOdCKowAjRvBCxTB9IW9uE15X1tgLa+AiEBDU9WlXO/F0+GK5Wi3NZVPjXhCWIvUXDt8FeCEQAbB1lzuFrgO1e0R0I+0gpHW9+i/zgcdyNp9WSvigE54g54MpzZbOAnMMaC5680uBxzahr3ylQYeYe1yLQNoVrX5Y7Fmb0TILZssyc4Wxgk6TS06U/NqYB1hGfJ19Y0mUV/icpyvV/3+UxtpM7IiKl3pb3wdNYQLLxbN9Db4H9glrxeOLX3aAduo90qHrpnSVOzWju+jAQpd/TrPipFDTjO2uGzjb9gNw== duydb2@gmail.com"
    ];
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
  ];

  # Enable service
  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
