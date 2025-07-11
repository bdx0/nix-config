{ config, lib, ... }:
let
  inherit (lib) types mkIf mergeAttrsList;
  cfg = config.bdx0.services.network-recovery;

  # ifaces = config.bdx0.services.network-recovery.interfaces;
  # ifaces = [ ];
  # ifaceConfig = (builtins.foldl' (acc: iface: acc // (genForIface iface)) { } ifaces);

  # ifaceConfig =
  #   (lib.mergeAttrsoist (map genForIface ifaces)); # (genForIface "enp2s0f0");
  # ifaceServices =
  #   # mkIf (cfg.interfaces != null && cfg.interfaces == [ "eth0" ])
  #   (lib.trace "${toString cfg.interfaces}" { });
  # (mergeAttrsList (map genForIface cfg.interfaces));
  # builtins.foldl' (acc: iface: acc // (genForIface iface)) { } cfg.interfaces;

in {
  options.bdx0.services.network-recovery = {
    enable = lib.mkEnableOption "Enable network recovery services.";
    wait-online = lib.mkEnableOption "Enable Waiting Online";
    dynamicIP = lib.mkEnableOption "Enable DHCP mode";
    interfaces = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of network interfaces to monitor and recover.";
    };
    ifaceServices = lib.mkOption {
      type = types.attrsOf types.anything;
      default = { };
      description = "";
    };
  };

  # config = (configModule config.bdx0.services.network-recovery pkgs);
  config = lib.mkMerge [{

    systemd.network.enable = lib.mkForce true;
    systemd.network.wait-online.anyInterface = lib.mkForce cfg.wait-online;
    # cfg.ifaceConfig = (lib.genAttrs cfg.interfaces genForIface);
  }

  # (lib.mkIf cfg.enable cfg.ifaceServices)
  # cfg.ifaceServices
  # (lib.mergeAttrsList (map genForIface ifaces)) # (genForIface "enp2s0f0");
  # (builtins.foldl' (acc: iface: acc // (genForIface iface)) { } ifaces)
  # (lib.trace "Ifaces: ${toString ifaces}")
  # (lib.genAttrs [ ] (iface: (lib.trace "${toString iface}" { })))
  # cfg.ifaceConfig
  # (lib.mkIf cfg.wait-online { })
    ];
}
