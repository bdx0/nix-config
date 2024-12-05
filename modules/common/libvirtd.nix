{ pkgs, ... }: {
  imports = [ ./vfio.nix ];
  options = { };
  config = {
    # "https://wiki.nixos.org/wiki/Libvirt"
    virtualisation.libvirtd.enable = true;
    # virtualisation.libvirtd.verbose = true;
    virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
    virtualisation.libvirtd.qemu.runAsRoot = true;
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
  };
}
