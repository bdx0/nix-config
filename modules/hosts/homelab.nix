# "https://www.youtube.com/watch?v=2yplBzPCghA&ab_channel=DreamsofAutonomy"
# "https://github.com/dreamsofautonomy/homelab/blob/main/nixos/configuration.nix"

{ meta, inputs, pkgs, modulesPath, lib, config, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.self.nixosModules.common
  ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = meta.system;
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  nix = {
    packages = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking.useDHCP = lib.mkDefault true;
  networking.hostName = meta.hostname;
  networking.wireless.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {

    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services.k3s = {
    enable = true;
    role = "server";
    token = "super-secret-token";
    extraFlags = toString ([
      ''--write-kubeconfig-mode "0644"''
      "--cluster-init"
      "--disable traefik"
      "--disable servicelb"
      "--disable localstorage"
    ] ++ (if meta.hostname == "homelab-0" then
      [ ]
    else
      [ "--server https://homelab-0:6443" ]));
    clusterInit = (meta.hostname == "homelab-0");
  };
  # fixes for longhorn
  system.tmpfiles.rules =
    [ "L+ /usr/local/bin - - - - /run/current-system/sw/bin" ];
  virtualisation.docker.logDriver = "json-file";

  services.openiscsi = {
    enable = true;
    name = "iqn.2016-04.com.open-iscsi:${meta.hostname}";
  };

  environment.systemPackages = with pkgs; [
    neovim
    k3s
    cifs-utils
    nfs-utils
    git
  ];

  system.stateVersion = "24.11";
}
