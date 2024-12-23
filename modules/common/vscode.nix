{ pkgs, modulesPath, lib, config, name ? null, ... }:
let cfg = config.bdx0.base;
in {
  imports = [ ];
  options.bdx0.vscode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "This is the config of vscode config";
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      vscode
      vscode.fhs
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions;
          [
            bbenoist.nix
            ms-python.python
            ms-azuretools.vscode-docker
            ms-vscode-remote.remote-ssh
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
            name = "remote-ssh-edit";
            publisher = "ms-vscode-remote";
            version = "0.47.2";
            sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
          }];
      })
    ];
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];
    };
  };

}

# "https://nixos.wiki/wiki/Visual_Studio_Code" # Remote_SSH
# "https://discourse.nixos.org/t/vscode-remote-ssh-on-nixos-could-not-start-dynamically-linked-executable-error/54591"
