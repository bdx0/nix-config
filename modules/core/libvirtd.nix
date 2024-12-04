{ pkgs, ... }: {
  imports = [
    ({ lib, config, ... }: {
      # "https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/"
      # "https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html"
      # "https://github.com/j-brn/nixos-vfio"
      # "https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/"
      # "https://discourse.nixos.org/t/nixos-vfio-gpu-passthrough/41169/3"
      # "https://github.com/mbilker/vgpu_unlock-rs/issues/15"
      # "https://www.google.com/search?q=vfio+device+doesn+t+support+migration&oq=vfio+device+d&gs_lcrp=EgZjaHJvbWUqCAgBEAAYFhgeMgYIABBFGDkyCAgBEAAYFhgeMggIAhAAGBYYHjIICAMQABgWGB4yCAgEEAAYFhgeMgoIBRAAGIAEGKIE0gEINTI1MmowajSoAgCwAgE&sourceid=chrome&ie=UTF-8"

      options.vfio.enable = with lib;
        mkEnableOption "Configure the machine for VFIO";
      config = let
        cfg = config.vfio;
        gpuIDs = [ ];
      in {
        boot = {
          initrd.kernelModules = [
            "vfio_pci"
            "vfio"
            "vfio_iommu_type1"
            "vfio_virqfd"

            "nvidia"
            "nvidia_modeset"
            "nvidia_uvm"
            "nvidia_drm"
          ];

          kernelParams = [
            # Intel
            "intel_iommu=on"
            "iommu=pt"
            # enable IOMMU
            # AMD
            "amd_iommu=on"
          ] ++ lib.optional cfg.enable
            # isolate the GPU
            ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
        };

        hardware.opengl.enable = true;
      };
    })
  ];

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
}
