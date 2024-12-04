{ self, inputs, pkgs, lib, config, ... }:
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
    microvm.vms = {
      # test = {
      #   autostart = true;
      #   inherit pkgs;
      #   config = { self, ... }: {
      #     imports = [
      #       self.nixosModules.common

      #       # common
      #     ];
      #     #     # system.stateVersion = config.system.version;

      #     networking.hostName = "test";
      #     users.users.root.password = "testtest";
      #   };
      # };
      test = {
        autostart = true;
        flake = self;
      };
    };
  };
}
