# "https://forum.level1techs.com/t/nixos-vfio-pcie-passthrough/130916"
# "https://www.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/"
# "https://www.reddit.com/r/NixOS/comments/e6y5n8/libvirt_gpu_passthrough_to_nixos_and_windows_vms/"
# "https://www.reddit.com/r/VFIO/comments/e6z8gt/libvirt_gpu_passthrough_to_nixos_and_windows_vms/"
# "https://www.reddit.com/r/NixOS/comments/17dvgkd/nixos_linuxvfio_kernel/"
# "https://www.reddit.com/r/NixOS/comments/oeosh5/hooks_in_libvirt/"
# "https://discourse.nixos.org/t/libvirt-installing-qemu-hook/385/7"
# "https://old.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/"
# "https://github.com/NixOS/nixpkgs/issues/98448"
# "https://wiki.nixos.org/wiki/Virt-manager"
# "https://discourse.nixos.org/t/i-cant-find-where-value-is-a-function-while-a-set-was-expected-comes-from-in-my-nix-module/46902"
# "https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html"
# "https://discourse.nixos.org/t/i-cant-find-where-value-is-a-function-while-a-set-was-expected-comes-from-in-my-nix-module/46902"
# "https://discourse.nixos.org/t/single-gpu-passthrough/44119"
# "https://discourse.nixos.org/t/nixos-vfio-gpu-passthrough/41169"
# "https://search.nixos.org/options?query=virtualisation.libvirtd"
# "https://www.youtube.com/watch?v=kAgIQGZUIP0&t=324s&ab_channel=PavolElsig"
# "https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/"
# "https://pastebin.com/AhwTYq39"
# "https://looking-glass.io/docs/B6/install/" # for-linux
# "https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html"
# "https://alexbakker.me/misc/libvirt-nt10.xml"
# "https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF"
# "https://github.com/j-brn/nixos-vfio"
# "https://gist.github.com/CRTified/43b7ce84cd238673f7f24652c85980b3"
# "https://github.com/CRTified/nur-packages/tree/master/modules"
# "https://github.com/CRTified/nur-packages/blob/master/flake.nix"
# "https://nixos.wiki/wiki/OSX-KVM"
# "https://nixos.wiki/wiki/Impermanence"
# "https://github.com/dustinlyons/nixos-config"
# "https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/"

# AMD
# "https://forum.level1techs.com/t/nixos-vfio-pcie-passthrough/130916"
# "https://alexbakker.me/post/nixos-pci-passthrough-qemu-vfio.html"
# "https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF"
# "https://github.com/Daholli/nixos-config"
# "https://gist.github.com/CRTified/43b7ce84cd238673f7f24652c85980b3"

{ pkgs, config, lib, ... }:
let cfg = config.bdx0.vfio;
in {
  options.bdx0.vfio = {
    enable = lib.mkEnableOption "VFIO Configuration";
    IOMMUType = lib.mkOption {
      description = "Type of the IOMMU";
      type = lib.types.enum [ "intel" "amd" ];
      example = "intel";
    };
    devices = lib.mkOption {
      description = "";
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    blacklistNvidia = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add Nvidia GPU modules to blacklist";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      boot.kernelModules =
        [ "vfio_pci" "vfio" "vfio_iommu_type1" "pci_stub" ]; # "amdgpu"
      boot.initrd.kernelModules =
        [ "vfio_pci" "vfio" "vfio_iommu_type1" "pci_stub" ]; # "amdgpu"
      boot.blacklistedKernelModules = lib.optionals cfg.blacklistNvidia [
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nouveau"
        # "amdgpu"
        "radeon"
        "i915"
      ];

      boot.extraModprobeConfig = (if (cfg.IOMMUType == "intel") then ''
        options kvm_intel nested=1
        options kvm_intel emulate_invalid_guest_state=0
        options kvm ignore_msrs=1
        options vfio-pci ${
          if (builtins.length cfg.devices > 0) then
            "ids=" + (lib.concatStringsSep "," cfg.devices)
          else
            ""
        } disable_vga=1
      '' else
        "options vfio-pci ${
          if (builtins.length cfg.devices > 0) then
            "ids=" + (lib.concatStringsSep "," cfg.devices)
          else
            ""
        } disable_vga=1\\n        ");
      boot.kernelParams = [ "iommu=pt" ]
        ++ (if (cfg.IOMMUType == "intel") then [
          "intel_iommu=on"
          "intel_iommu=igfx_off"
        ] else
          [ "amd_iommu=on" ]);
      # ++
      # # isolate GPU
      # (lib.optional (builtins.length cfg.devices > 0)
      #   ("vfio-pci.ids=" + lib.concatStringsSep "," cfg.devices));
      hardware.opengl.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;
    })
  ];
}
