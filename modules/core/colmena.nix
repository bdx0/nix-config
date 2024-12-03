{ name, lib, ... }: {

  networking.hostName = lib.mkDefault name;
  # DEPLOYMENT
  deployment.targetHost = name;
  deployment = {
    targetUser = "root";
    buildOnTarget = true;
  };
}
