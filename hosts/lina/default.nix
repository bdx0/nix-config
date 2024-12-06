{ inputs, config, pkgs, lib, name, ... }: {
  imports = [
    inputs.self.nixosModules.common

    inputs.self.nixosModules.server
  ];
  config = {
    boot.initrd.availableKernelModules = [

      "sr_mod"
      "usbhid"
      "nvme"
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usb_storage"
      "sd_mod"
    ];

    boot.kernelParams = [
      "intel_iommu=on"
      "iommu=pt"
      #  ''vfio-pci.ids=""''
    ];
    boot.kernelModules = [ "kvm-intel" "vfio-pci" ];
    boot.blacklistedKernelModules = [ "nouveau" "nvidia" ];
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/2BF7-EA6A";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    fileSystems."/" = {
      device = "/dev/mapper/lina--vg-root";
      fsType = "ext4";
    };
    swapDevices = [ ];
    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;

    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.systemd-boot.enable = true;

    # config with efiInstallAsRemovable = true
    boot.loader.efi.canTouchEfiVariables = true;

    # boot.loader.grub.enable = true;
    # boot.loader.grub.version = 2;
    # boot.loader.grub.efiSupport = true;
    # boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
    # boot.loader.grub.device = "nodev";
    # boot.loader.grub.useOSProber = true;
    # boot.loader.grub.efiInstallAsRemovable = true;

    boot.tmp.cleanOnBoot = true;
    zramSwap.enable = false;
    networking.domain = "lina.bdx0.io.vn";
    common.dvm.enable = true;

    users.defaultUserShell = pkgs.bash;
    programs.bash.interactiveShellInit = "figurine ${name}";
    nixpkgs.config.allowUnfree = true;
  };
}
