{ ... }: {
  options = { };
  config = {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };
    services.dockerRegistry.enable = true;
  };
}
