{ lib, ... }@args: {
  config = lib.mkMerge [
    (if (builtins.hasAttr "name" args) then {
      networking.hostName = lib.mkDefault args.name;
      # DEPLOYMENT
      deployment.targetHost = args.name;
    } else
      { })
    {
      deployment = {
        targetUser = "root";
        buildOnTarget = true;
      };
    }
  ];
}
