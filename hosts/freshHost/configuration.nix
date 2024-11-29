{ modulesPath, pkgs, vscode-server, ssh-keys, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    vscode-server.nixosModules.default
    ./hardware-configuration.nix
    # "${
    #   (builtins.fetchTarball {
    #     url = "https://github.com/numtide/nixos-facter-modules/";
    #   })
    # }/modules/nixos/facter.nix"
  ];

  # config.facter.reportPath = ./facter.json;
  nix = {
    package = pkgs.nixVersions.stable;
    settings.experimental-features = [ "nix-command" "flakes" ];
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
    google-authenticator
  ];

  # Enable service
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.KbdInteractiveAuthentication = true;
  # ssh auth over google auth
  # "https://discourse.nixos.org/t/setting-up-google-authenticator-for-ssh/36931/7"
  security.pam = { services.sshd.googleAuthenticator.enable = true; };
  # "https://discourse.nixos.org/t/dont-prompt-a-user-for-the-sudo-password/9163/2"
  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraRules = [{
    users = [ "dd" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }
  # # Allow execution of any command by all users in group sudo,
  # # requiring a password.
  # {
  #   groups = [ "sudo" ];
  #   commands = [ "ALL" ];
  # }

  # # Allow execution of "/home/root/secret.sh" by user `backup`, `database`
  # # and the group with GID `1006` without a password.
  # {
  #   users = [ "backup" "database" ];
  #   groups = [ 1006 ];
  #   commands = [{
  #     command = "/home/root/secret.sh";
  #     options = [ "SETENV" "NOPASSWD" ];
  #   }];
  # }

  # # Allow all users of group `bar` to run two executables as user `foo`
  # # with arguments being pre-set.
  # {
  #   groups = [ "bar" ];
  #   runAs = "foo";
  #   commands = [
  #     "/home/baz/cmd1.sh hello-sudo"
  #     {
  #       command = ''/home/baz/cmd2.sh ""'';
  #       options = [ "SETENV" ];
  #     }
  #   ];
  # }
    ];
  users.users.root = {
    openssh.authorizedKeys.keys =
      pkgs.lib.splitString "\n" (builtins.readFile ssh-keys.outPath);
  };

  networking.firewall.enable = false;
  # How to move this into a seperate file?
  services.vscode-server.enable = true;
  # services.gitwatch.various-config = {
  #   enable = true;
  #   path = "/home/dd/code/nix-config/";
  #   remote = "git@github.com:bdx0/nix-config.git";
  #   user = "dd";
  # };
  services.tor = {
    enable = true;

  };

  system.stateVersion = "24.05";
}
