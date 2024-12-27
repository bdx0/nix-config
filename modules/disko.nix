{
  btrfs = { config, inputs, lib, ... }:
    let cfg = config.bdx0.disko;
    in {
      imports = [ inputs.disko.nixosModules.disko ];
      options.bdx0.disko = {
        enable = lib.mkEnableOption "Enable disko";
        disks = lib.mkOption {
          type = lib.types.listOf lib.types.string;
          description = "Disks to partition";
          default = [ "/dev/vda" ];
        };
      };
      # _module.args.disks = [ "/dev/vda" ];
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
      config.disko.devices = lib.mkIf cfg.enable {
        disk = {
          mydisk = {
            device = (builtins.elemAt cfg.disks 0);
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
                    type = "btrfs";
                    # type = "filesystem";
                    # format = "bcachefs";
                    # format = "brtfs";
                    # format = "xfs";
                    mountpoint = "/";
                    extraArgs = [ "-f" ];
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };

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
  old = { config, inputs, lib, ... }:
    let cfg = config.bdx0.disko;
    in {
      imports = [ inputs.disko.nixosModules.disko ];
      options.bdx0.disko = {
        enable = lib.mkEnableOption "Enable disko";
        disks = lib.mkOption {
          type = lib.types.listOf lib.types.string;
          description = "Disks to partition";
          default = [ "/dev/vda" ];
        };
      };
      # { lib, ... }: {

      config.disko.devices = {
        disk = {
          mydisk = {
            # device = (builtins.elemAt disks 0);
            device = (builtins.elemAt cfg.disks 0);
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
    };

}
