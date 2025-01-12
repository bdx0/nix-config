{ inputs, ... }: {
  imports = [
    inputs.self.nixosModules.common
    inputs.self.nixosModules.containers
    inputs.impermanence.nixosModules.impermanence
  ];
  config = {

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    bdx0.hardware.enable = true;
    bdx0.hardware.type = "intel";
    bdx0.container.engine = "docker";

    boot.loader.grub.device = "/dev/vda";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
      fsType = "xfs";
    };

    nixpkgs.config.allowUnfree = true;
    programs.nix-ld.enable = true;

    bdx0.services.monit.enable = true;
    bdx0.services.monit.address = "100.79.175.84";
    # bdx0.containers.hello_world.enable = true;
    # bdx0.containers.postgres.enable = true;

    #   containers.postgres = {
    #     autoStart = true;
    #     # pass the private key to the container for agenix to decrypt the secret
    #     bindMounts."/etc/ssh/ssh_host_ed25519_key".isReadOnly = true;
    #     config = { pkgs, lib, ... }: {
    #       imports = [ inputs.agenix.nixosModules.default ];
    #       # imports = [ inputs.self.nixosModules.common ];

    #       # services.pgadmin = let initialEmail = "admin@nix01.bdx0.io.vn";
    #       # in {
    #       #   inherit initialEmail;
    #       #   enable = true;
    #       #   settings = {
    #       #     "ALLOW_HOSTS" = [ "*" ];
    #       #     "DEFAULT_SERVER" = "0.0.0.0";
    #       #   };
    #       #   initialPasswordFile = config.age.secrets.pg_pass.path;
    #       # };
    #       services.postgresql.enable = true;
    #     };
    #   };
  };
}
