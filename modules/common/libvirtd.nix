{ pkgs, config, lib, ... }:
let cfg = config.bdx0.libvirtd;
in {
  imports = [ ./vfio.nix ];
  options.virtualisation.libvirtd = {
    deviceACL = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  options.bdx0.libvirtd = { enable = lib.mkEnableOption "Enable libvirtd"; };
  config = lib.mkIf cfg.enable {
    # required bylibvirtd
    security.polkit.enable = true;
    # "https://wiki.nixos.org/wiki/Libvirt"
    virtualisation.libvirtd.enable = true;
    # virtualisation.libvirtd.verbose = true;
    virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
    virtualisation.libvirtd.qemuOvmf = true;
    virtualisation.libvirtd.qemu.runAsRoot = true;
    # virtualisation.libvirtd.allowedBridges = [ "br0"];
    # Enable TPM emulation (optional)
    virtualisation.libvirtd.qemu.swtpm.enable = true;
    virtualisation.libvirtd.qemu.ovmf.enable = true;
    virtualisation.libvirtd.qemu.ovmf.packages = [
      pkgs.OVMFFull.fd
      pkgs.pkgsCross.aarch64-multiplatform.OVMF.fd
      # (pkgs.OVMF.override {
      #   secureBoot = true;
      #   tpmSupport = true;
      # }).fd
    ];
    # Enable USB redirection (optional)
    virtualisation.spiceUSBRedirection.enable = true;
    # services.libvirtd.enable = true;
    virtualisation.libvirtd.deviceACL = [ ];
    bdx0.vfio.enable = true;
    environment.systemPackages = with pkgs; [

      qemu
      qemu_kvm
      libvirt
      OVMF
      guestfs-tools
    ];
  };
}
