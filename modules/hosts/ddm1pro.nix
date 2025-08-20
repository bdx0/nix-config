# "https://evantravers.com/articles/2024/02/06/switching-to-nix-darwin-and-flakes/"
# "https://nixcademy.com/posts/nix-on-macos/"
# "https://davi.sh/til/nix/nix-macos-setup/"
# "https://blog.dbalan.in/"
# "https://davi.sh/blog/2024/01/nix-darwin/"
# https://github.com/nmasur/dotfiles/blob/c53f1470ee04890f461796ba0d14cce393f2b5c3/modules/darwin/homebrew.nix

{ self, lib, config, pkgs,  meta,  ...
}: {
  imports = [
    #    nix-homebrew.darwinModules.nix-homebrew 
  ];
  config = let
    inherit (meta) username;
    inherit (lib) mkDefault; # mkForce mkIf;
    # inherit (pkgs.stdenv) isLinux isDarwin;
    _pkgs = with pkgs; [
      coreutils
      tree
      pstree

      # linux utils
      util-linux
      binutils
      mkalias
      starship
      zoxide
      watch

      wezterm
      google-chrome
      nnn
      yazi
      tig
      lazygit
      lazydocker
      k9s
      talosctl
      fzf
    ];
  in {
    environment.systemPackages = _pkgs;
    environment.systemPath = [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];
    environment.pathsToLink = [ "/Applications/" ];
    # security.pam.enableSudoTouchIdAuth = true;
    security.pam.services.sudo_local.touchIdAuth = true;
    # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
    system.defaults = {
      dock.autohide = mkDefault true;
      dock.mru-spaces = true;
      dock.show-recents = true;
      dock.show-process-indicators = true;
      dock.orientation = "right";
      dock.static-only = true;
      dock.persistent-apps = [ ];
      finder.FXPreferredViewStyle = "clmv";
      finder.ShowPathbar = true;
      loginwindow.LoginwindowText = "bdx0";
      screencapture.location = "~/Documents/Screenshots";
      screensaver.askForPasswordDelay = 10;
      NSGlobalDomain.AppleICUForce24HourTime = true;
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.system-features = [ "apple-virt" "hvf" ];
    # kvm nixos-test
    nix.settings.trusted-users = [ "@admin" "dd" "root" ];
    nix.settings.allowed-users = [ "dd" "root" ];
    nix.settings.extra-platforms = [ "x86_64-darwin" "aarch64-darwin" ];

    # nix.gc.user = "root";
    # nix.optimise.user = "root";
    nix.settings.sandbox = false;
    nix.package = pkgs.nix;

    nix.extraOptions = ''
      auto-optimise-store = true
    '';

    # Install fonts 
    fonts.packages = with pkgs; [
      dejavu_fonts
      hack-font
      nerd-fonts.hasklug
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

    # https://discourse.nixos.org/t/nix-darwin-homebrew-masapps-is-hanging/60828
    # nix-homebrew = {
    #   enable = false;
    #   user = username;
    #   enableRosetta = false;
    #   taps = {
    #     "homebrew/homebrew-core" = homebrew-core;
    #     "homebrew/homebrew-cask" = homebrew-cask;
    #     # "homebrew/homebrew-bundle" = homebrew-bundle;
    #     "oven-sh/homebrew-bun" = homebrew-bun;
    #   };
    #   mutableTaps = false;
    #   autoMigrate = true;
    # };
    homebrew = {
      enable = true;
      global = {
        brewfile = true;
        autoUpdate = true;
      };
      taps = [ "oven-sh/bun" "homebrew/core" "homebrew/cask" ];
      brews = [
        "mas"
        "lima"
        "podman"
        "pipx"
        "tmux"
        "bun"
        "huggingface-cli"
        "restic"
        "ripgrep"
        "brotli"
        "glances"
        "git-lfs"
        "gettext"
        "nnn"
        "yazi"
        "tig"
        "lazygit"
        "k9s"
        "talosctl"
        "fzf"
      ];
      casks = [
        "dbeaver-community"
        "raspberry-pi-imager"
        "visual-studio-code"
        # "firefox"
        "hammerspoon"
        "obsidian"
        "raycast"
        "keycastr"
        "google-chrome"
        "stats"
        "zoom"
        "vlc"
        "zerotier-one"
        "basictex"
        "macfuse"
        "iina"
        "crystalfetch"
        # Font install
        "font-fira-code-nerd-font"
        "font-hack-nerd-font"
        "font-hasklug-nerd-font"
        "font-inconsolata-nerd-font"
        "font-jetbrains-mono-nerd-font"
        "wezterm"

      ];
      masApps = mkDefault {
        # "https://discourse.nixos.org/t/brew-not-on-path-on-m1-mac/26770/3"
        # Xcode = 497799835;
        # "Yoink" = 457622435;
      };

      onActivation.cleanup = "zap";
      onActivation.autoUpdate = true;
    };
    users.users.${username} = {
      name = username;
      home = "/Users/${username}";
      shell = pkgs.zsh;
    };

    # programs.home-manager.enable = true;
    programs.zsh.enable = true;
    programs.zsh.enableBashCompletion = true;
    programs.zsh.enableFzfCompletion = true;
    programs.zsh.enableFzfGit = true;
    programs.zsh.enableFzfHistory = true;
    programs.zsh.enableAutosuggestions = true;
    programs.zsh.enableCompletion= true;
    programs.zsh.enableSyntaxHighlighting = true;
    programs.zsh.promptInit= ''
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
    '';
    # programs.direnv.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    # nix-darwin requirements
    system.configurationRevision =
      mkDefault (self.rev or self.dirtyRev or null);
    system.stateVersion = 4;
    # https://github.com/philingood/nix-config/blob/cb3555c9cdff1bddbcd866e129c706144c20493c/modules/darwin/core.nix#L111
    system.activationScripts.extraActivation = { enable = true; };
    # system.activationScripts.postUserActivation.text = ''
    #   # defaults delete com.apple.menuextra.battery ShowPercent
    #   # Following line should allow us to avoid a logout/login cycle
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    #   echo "DONE DONE DONE"
    # '';
    system.primaryUser = "dd";

    # Auto upgrade nix package and the daemon service.
    # services.nix-daemon.enable = true;
    # services.activate-system.enable = true;

    networking.knownNetworkServices = [ "Wi-Fi" "Ethernet" ];
    networking.dns = [ "1.1.1.1" "1.0.0.1" "8.8.8.8" ];

    nix.enable = false;
    nix.gc.automatic = config.nix.enable;
    nix.gc.options =
      "--max-freed $((25 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | awk '{ print $4 }')))";
    # nix.configureBuildUsers = true;
    nix.optimise.automatic = config.nix.enable;
  };

}
