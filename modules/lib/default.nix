# "https://github.com/EmergentMind/nix-config/blob/dev/lib/default.nix"
{
  test = { lib, ... }: {
    # use path relative to the root of the project
    relativeToRoot = lib.path.append ../.;
    scanPaths = path:
      builtins.map (f: (path + "/${f}")) (builtins.attrNames
        (lib.attrsets.filterAttrs (path: _type:
          (_type == "directory") # include directory
          || ((path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )) (builtins.readDir path)));
  };
  configForIfaces = ifaces: pkgs:
    let
      genForIface = iface: pkgs:
        let
          recoveryScript = pkgs.writeShellScript "recovery-${iface}-script" ''
            if ! ${pkgs.iputils}/bin/ping -c3 -W2 8.8.8.8; then
              ${pkgs.iproute2}/bin/ip link set ${iface} down
              sleep 1
              ${pkgs.iproute2}/bin/ip link set ${iface} up
              sleep 2
              ${pkgs.iputils}/bin/ping -c3 -W2 8.8.8.8 || echo "Network still down"
            fi
          '';
          checkScript = pkgs.writeShellScript "check-${iface}-script" ''
            if ! ${pkgs.iputils}/bin/ping -c3 -W2 8.8.8.8; then
              systemctl start net-recovery-${iface}.service
            fi
          '';
        in {
          systemd.services."net-recovery-${iface}" = {
            enable = true;
            description = "Recover ${iface} and health-check";
            wants = [ "network-link-${iface}.service" ];
            after = [ "network-link-${iface}.service" ];
            path = [ pkgs.iproute2 pkgs.iputils ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${recoveryScript}";
            };
          };
          systemd.services."net-health-${iface}" = {
            enable = true;
            description = "Ping check and recovery for ${iface}";
            wants = [ "net-recovery-${iface}.service" ];
            after = [ "net-recovery-${iface}.service" "network-online.target" ];
            path = [ pkgs.iproute2 pkgs.iputils ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${checkScript}";
            };
          };
          systemd.timers."net-health-${iface}" = {
            enable = true;
            description = "Run net-health-${iface} every 2 minutes";
            timerConfig = {
              OnBootSec = "1s";
              OnCalendar = "*:0/1";
              # onCalendar = "*-*-* *:00:05";
              # onCalendar = "hourly";
            };
            wantedBy = [ "timers.target" ];
          };
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
    in (builtins.foldl' (acc: iface:
      # acc // ((genForIface iface) pkgs) // (dynamicIPForIface iface)) { }
      acc // ((genForIface iface) pkgs)) { } ifaces);

  configModule = cfg:
    { lib, pkgs }:
    lib.mkMerge [
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
            systemd.services."net-health-${iface}" = {
              description = "Ping check and recovery for ${iface}";
              wants = [ "net-recovery-${iface}.service" ];
              after =
                [ "net-recovery-${iface}.service" "network-online.target" ];
              path = [ pkgs.iproute2 ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = ''
                  if ! ping -c3 -W2 8.8.8.8; then
                                      systemctl start net-recovery-${iface}.service
                                    fi'';
              };
            };
            systemd.timers."net-health-${iface}.timer" = {
              description = "Run net-health-${iface} every 5 minutes";
              timeConfig = { onCalendar = "*:0/5"; };
              wantedBy = [ "timers.target" ];
            };
          };
        dynamicIPForIface = iface: {
          systemd.network.networks."10-${iface}" = {
            matchConfig.name = iface;
            networkConfig = {
              DHCP = "yes";
              IPv6AcceptRA = true;
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
        mergedConfig = builtins.foldl'
          (acc: iface: acc // (genForIface iface) // (dynamicIPForIface iface))
          { } cfg.interfaces;
        # mergedConfig = (genForIface [ "enp2s0f0" ]);
      in mergedConfig))
    ];
}
