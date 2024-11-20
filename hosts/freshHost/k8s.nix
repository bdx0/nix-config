{ lib, pkgs, ... }:
let
  kuberMasterIP = "192.168.42.20";
  kuberMasterHostname = "kuber-master";
  kuberMasterAPIServerPort = 6443;
in {
  networking.extraHosts = "${kuberMasterIP} ${kuberMasterHostname}";
  environment.systemPackages = with pkgs; [ kubernetes kubectl ];
  services.kubernetes.roles = [ "master" "node" ];
  services.kubernetes.masterAddress = kuberMasterHostname;
  services.kubernetes.apiserverAddress =
    "https://${kuberMasterHostname}:${kuberMasterAPIServerPort}";
  services.kubernetes.easyCerts = true;
  services.kubernetes.apiserver.securePort = kuberMasterAPIServerPort;
  services.kubernetes.apiserver.advertiseAddress = kuberMasterIP;

  # use coredns
  services.kubernetes.addons.dns.enable = true;

  # needed if you use swap
  services.kubernetes.kubelet.extraOpts = "--fail-swap-on=false";
}
