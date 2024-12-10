{ modulesPath, lib, config, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  options = {
    qemuSystem.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "This is a qemu system";
    };
  };
  config = lib.mkIf config.qemuSystem.enable {

  };
}
