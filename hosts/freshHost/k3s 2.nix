{ pkgs, meta, ... }: {
  # Fixes for longhorn
  systemd.tmpfiles.rules =
    [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" ];
  virtualisation.docker.logDriver = "json-file";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = /var/lib/rancher/k3s/server/token;
    extraFlags = toString ([
      ''--write-kubeconfig-mode "0644"''
      "--cluster-init"
      "--disable servicelb"
      "--disable traefik"
      "--disable local-storage"
    ] ++ (if meta.hostname == "homelab-0" then
      [ ]
    else
      [ "--server https://homelab-0:6443" ]));
    clusterInit = (meta.hostname == "homelab-0");
  };

  environment.systemPackages = with pkgs; [ k3s cifs-utils nfs-utils ];
}
