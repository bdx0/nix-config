{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.bdx0.services.network-recovery;
in {
  options.bdx0.services.network-recovery = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Enable network recovery services.";
    };
    wait-online = lib.mkEnableOption "Enable Waiting Online";
    dynamicIP = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Enable DHCP mode";
    };
    interfaces = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of network interfaces to monitor and recover.";
    };
  };
  config = lib.mkMerge [
    { systemd.network.enable = lib.mkForce true; }
    (lib.mkIf cfg.enable (let
      genForIface = iface:
        let
          recoveryScript = pkgs.writeShellScript "recovery-${iface}-script" ''
            ${pkgs.iproute2}/bin/ip link set ${iface} down
            sleep 1
            ${pkgs.iproute2}/bin/ip link set ${iface} up
            ping -c3 -W2 8.8.8.8 || echo "Network still down"
          '';
        in {
          systemd.services."net-recovery-${iface}" = {
            description = "Recover ${iface} and health-check";
            wants = [ "network-link-${iface}.service" ];
            after = [ "network-link-${iface}.service" ];
            path = [ pkgs.iproute2 ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${recoveryScript}";
            };
          };
          #     systemd.services."net-health-${iface}" = {
          #       description = "Ping check and recovery for ${iface}";
          #       wants = [ "net-recovery-${iface}.service" ];
          #       after = [ "net-recovery-${iface}.service" "network-online.target" ];
          #       path = [ pkgs.iproute2 ];
          #       serviceConfig = {
          #         Type = "oneshot";
          #         ExecStart =
          #           "ping -c3 -W2 8.8.8.8 || systemctl start net-recovery-${iface}.service";
          #       };
          #     };
          #     systemd.timers."net-health-${iface}.timer" = {
          #       description = "Run net-health-${iface} every 5 minutes";
          #       timeConfig = { onCalendar = "*:0/5"; };
          #       wantedBy = [ "timers.target" ];
          #     };
        };
      # dynamicIPForIface = iface: {
      #   systemd.network.networks."10-${iface}" = {
      #     matchConfig.name = iface;
      #     networkConfig = {
      #       DHCP = "yes";
      #       IPv6AcceptRA = true;
      #     };
      #     linkConfig.RequiredForOnline = "routable";
      #   };
      # };
      # mergedConfig = builtins.foldl'
      #   (acc: iface: acc // (genForIface iface) // (dynamicIPForIface iface)) { }
      #   cfg.interfaces;
      # mergedConfig =
      # builtins.foldl' (acc: iface: acc // (genForIface iface)) { }
      # ;
    in (builtins.foldl' (acc: iface: acc) { } cfg.interfaces)))
    (lib.mkIf cfg.wait-online {
      systemd.network.wait-online.anyInterface = true;
    })
  ];
}
