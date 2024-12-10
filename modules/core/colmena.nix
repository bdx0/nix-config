{ name ? null, lib, ... }: {
  imports = [ ];
  options = { };
  config = lib.mkIf (name != null) {
    networking.hostName = lib.mkDefault name;
    # DEPLOYMENT
    deployment.targetHost = name;
    deployment = {
      targetUser = "root";
      buildOnTarget = true;
    };
  };
}
