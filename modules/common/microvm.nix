{ inputs, pkgs, lib, config, ... }:
let cfg = config.common;
in {
  options.common = {
    dvm.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable MicroVM system";
    };
  };
  # imports = [ ]
  #   ++ (lib.optionals (cfg.dvn.enable) [ inputs.microvm.nixosModules.host ]);

  imports = [ inputs.microvm.nixosModules.host ];

  config = lib.mkIf (cfg.dvm.enable) {
    microvm = {
      autostart = [ "test" "test2" ];
      vms = {
        test2 = {
          autostart = true;
          inherit pkgs;
          config = { ... }: {
            imports = [
              inputs.self.nixosModules.common
              inputs.self.nixosModules.vm

              # common
            ];
            #     # system.stateVersion = config.system.version;

            networking.useNetworkd = true;
            networking.hostName = "test2";
            users.users.root.password = "testtest";
            # nixpkgs.config.allowUnfree = true;
          };
        };
        test = {
          flake = inputs.self;
          updateFlake = "github:bdx0/nix-config?ref=mkOptions";
        };
      };
    };
  };
}
