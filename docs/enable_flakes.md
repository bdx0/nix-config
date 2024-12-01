# enable flake

## Articles

- [Convert configuration.nix to be a flake](https://nixos.asia/en/configuration-as-flake)

## [From flake file](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled)

- edit file /etc/nixos/configuration.nix

  ```nix
  {config, pkgs, ...}:
  {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      environment.systemPackages = with pkgs; [
          git
          wget
          curl
          neovim
      ];

      # Set the default editor to vim
      environment.variables.EDITOR = "nvim";

  }
  ```

## [Plain nix (not nixos)](https://youtu.be/JCeYq72Sko0?t=106)

- edit file ~/.config/nix/nix.conf or /etc/nix/nix.conf

```bash
experimentall-features = nix-command flake
```

## [From command](https://nixos.asia/en/configuration-as-flake)

- append `--extra-experimental-features "nix-command flakes"` after nix command

```bash
nix --extra-experimental-features "nix-command flakes" flake show
```
