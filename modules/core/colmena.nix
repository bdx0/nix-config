{ lib, ... }@args: {
  imports = [ ];
  options = { };
  config = if (builtins.hasAttr "name" args) then {
    networking.hostName = lib.mkDefault args.name;
    # DEPLOYMENT
    deployment.targetHost = args.name;
    deployment = {
      targetUser = "root";
      buildOnTarget = true;
    };
  } else
    { };
}
