# usage
# inputs = {
#   disko.url = "github:nix-community/disko";
#   disko.inputs.nixpkgs.follows = "nixpkgs";
# };
# {
#   modules = [
#       disko.nixosModules.disko
#        <path>/vm/disko.nix
#       {
#           _module.args.disks =[ "/dev/vda" ];
#       }
#   ];
# }
{ disks ? [ "/dev/vda" ], ... }: {
  # { lib, ... }: {
  disko.devices = {
    disk = {
      mydisk = {
        device = (builtins.elemAt disks 0);
        # device = lib.mkDefault "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub mbr
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              end = "-8G";
              content = {
                type = "filesystem";
                # format = "bcachefs";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
