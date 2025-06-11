{ inputs, pkgs, lib, ... }: {
  imports =
    [ inputs.self.nixosModules.common inputs.self.nixosModules.disko.btrfs ];
  config = lib.mkMerge [
    {
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      bdx0.hardware.enable = true;
      bdx0.hardware.type = "intel";
      bdx0.container.engine = "docker";

      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        glibc
        # Thêm các thư viện cần thiết khác nếu cần
      ];

      bdx0.goku01.environment.systemPackages = with pkgs;
        let
          uvEnv = buildFHSUserEnv {
            name = "uv-env";
            targetPkgs = pkgs: with pkgs; [ uv python3 ];
            runScript = "bash";
          };

        in lib.mkAfter [
          wget
          cmatrix
          tmux
          lazydocker
          snapraid
          mergerfs
          mergerfs-tools
          steam-run
          uvEnv
        ];

      # main system
      boot.loader.grub.device = "/dev/vda";

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/d00f6f52-c387-47b7-b0a7-5180d509707c";
        fsType = "xfs";
      };

      ## Configuration for snapraid + mergerfs
      systemd.tmpfiles.rules = [
        "d /mnt/disk1/data 0755 root root"
        "d /mnt/disk2/data 0755 root root"
        "d /mnt/disk3/data 0755 root root"
        "d /mnt/disk4/data 0755 root root"
        # "d /mnt/parity1 0755 root root"
        # "d /mnt/storage 0755 root root"
        # "d /mnt/storage/public 0755 nobody nogroup -"
        "d /mnt/storage/public 2775 nobody sambashare -"
        "d /mnt/storage/dd 0700 dd wheel -"
      ];
    }
    {

      # systemd.services.ensureDataDirs = {
      #   wantedBy = [ "multi-user.target" ];
      #   after = [ "local-fs.target" ];
      #   script = ''
      #     [ -d /mnt/disk1/data ] || mkdir -p /mnt/disk1/data
      #     [ -d /mnt/disk2/data ] || mkdir -p /mnt/disk2/data
      #     [ -d /mnt/disk3/data ] || mkdir -p /mnt/disk3/data
      #     [ -d /mnt/disk4/data ] || mkdir -p /mnt/disk4/data
      #   '';
      # };
      # #!/bin/bash
      # for i in b c d e; do
      #   dev="/dev/sd$i"
      #   echo "Formatting $dev..."
      #   mkfs.ext4 -F "$dev"
      # done
      fileSystems."/mnt/disk1" = {
        device = "UUID=63a077da-ef18-4513-8d7b-9392af466c04";
        fsType = "ext4";
      };
      fileSystems."/mnt/disk2" = {
        device = "UUID=64027999-a291-440b-84f6-d1ec3e121bbf";
        fsType = "ext4";
      };
      fileSystems."/mnt/disk3" = {
        device = "UUID=11fc239e-7ad8-4202-9429-e62365dc4fc0";
        fsType = "ext4";
      };
      fileSystems."/mnt/disk4" = {
        device = "UUID=cf89a235-2dbd-426f-ae9e-f0cf4b58e481";
        fsType = "ext4";
      };
      fileSystems."/mnt/parity1" = {
        device = "UUID=0aa27db7-b80c-43e1-a865-b2b53f2fe649";
        fsType = "ext4";
      };

      # fileSystems."/mnt/storage" = {
      #   neededForBoot = true;
      #   device =
      #     "mergerfs#/mnt/disk1/data:/mnt/disk2/data:/mnt/disk3/data:/mnt/disk4/data";
      #   fsType = "fuse.mergerfs";
      #   options = [
      #     "defaults"
      #     "allow_other"
      #     "use_ino"
      #     "category.create=mfs"
      #     "moveonenospc=true"
      #     "cache.files=partial"
      #   ];
      # };
      systemd.mounts = [{
        what =
          "mergerfs#/mnt/disk1/data:/mnt/disk2/data:/mnt/disk3/data:/mnt/disk4/data";
        where = "/mnt/storage";
        type = "fuse.mergerfs";
        options = lib.concatStringsSep "," [
          "defaults"
          "allow_other"
          "use_ino"
          "category.create=mfs"
          "moveonenospc=true"
          "cache.files=partial"
        ];
        wantedBy = [ "multi-user.target" ];
      }];
      # systemd.mergerfs.mount = {
      #   after = [ "local-fs.target" ];
      #   wantedBy = [ "multi-user.target" ];
      # };

      ### 1. snapraid.conf
      environment.etc."snapraid.conf".text = ''
        parity /mnt/parity1/snapraid.parity

        content /mnt/disk1/snapraid.content
        content /mnt/disk2/snapraid.content
        content /mnt/disk3/snapraid.content
        content /mnt/disk4/snapraid.content
        content /root/snapraid.content

        data d1 /mnt/disk1/data
        data d2 /mnt/disk2/data
        data d3 /mnt/disk3/data
        data d4 /mnt/disk4/data

        exclude *.unrecoverable
        exclude /lost+found/
        exclude *.bak
      '';
      ### 2. snapraid-sync script
      # environment.etc."snapraid-sync.sh".text = ''
      #   #!/bin/sh
      #   # Check if disks are mounted
      #   for i in /mnt/disk{1,2,3,4} /mnt/parity1; do
      #     mountpoint -q "$i" || {
      #       echo "❌ Missing mount: $i" >&2
      #       exit 1
      #     }
      #   done

      #   # Run scrub + sync
      #   exec ${pkgs.snapraid}/bin/snapraid -c /etc/snapraid.conf scrub >> /var/log/snapraid.log 2>&1 && \
      #   exec ${pkgs.snapraid}/bin/snapraid -c /etc/snapraid.conf sync >> /var/log/snapraid.log 2>&1
      # '';
      # environment.etc."snapraid-sync.sh".mode = "0555";

      ### 3. systemd service
      systemd.services.snapraid-healthcheck = let
        script = pkgs.writeShellScript "snapraid-healthcheck" ''
          for i in /mnt/disk{1,2,3,4} /mnt/parity1; do
            if ! mountpoint -q "$i"; then
              echo "❌ Missing mount: $i" >&2
              exit 1
            fi
          done
        '';
      in {
        description = "Verify SnapRAID mount state";
        path = with pkgs; [ util-linux ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${script}";
        };
      };
      systemd.services.snapraid-sync = let
        script = pkgs.writeShellScript "snapraid-sync" ''
          # Check if disks are mounted
          for i in /mnt/disk{1,2,3,4} /mnt/parity1; do
            mountpoint -q "$i" || {
              echo "❌ Missing mount: $i" >&2
              exit 1
            }
          done

          # Run scrub + sync
          exec ${pkgs.snapraid}/bin/snapraid -c /etc/snapraid.conf scrub >> /var/log/snapraid.log 2>&1 && \
          exec ${pkgs.snapraid}/bin/snapraid -c /etc/snapraid.conf sync >> /var/log/snapraid.log 2>&1
        '';
      in {
        description = "SnapRAID periodic sync";
        after = [ "snapraid-healthcheck.service" ];
        # environment = {
        #   PATH =
        #     "${pkgs.util-linux}/bin:/run/wrappers/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        # };
        # wantedBy = [ "timers.target" ];
        # wants = [ ];
        path = with pkgs; [ util-linux ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${script}";
          StandardOutput = "journal";
          StandardError = "journal";
          # RemainAfterExit = true;
        };
      };

      ### 4. systemd timer (hàng ngày)
      systemd.timers.snapraid-sync = {
        description = "Run SnapRAID sync hourly";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          # OnCalendar = "daily";
          OnCalendar = "*-*-* 0,6,12,18:00:00"; # mỗi 6h
          # OnCalendar = "hourly"; # ⬅️ đổi từ "daily" sang "hourly"
          # OnCalendar = "*:00/2"; # mỗi 2 giờ
          # OnCalendar = "*:00/15"; # mỗi 15 phút
          Persistent = true;
        };
      };
      # Tự động chạy sync hàng ngày lúc 1h sáng
      # services.cron.systemCronJobs = [
      #   "0 1 * * * root snapraid sync >> /var/log/snapraid-sync.log 2>&1"
      #   "30 1 * * 0 root snapraid scrub -p 1 >> /var/log/snapraid-scrub.log 2>&1"
      # ];
      # systemd.timers.snapraid-sync = {
      #   description = "Run SnapRAID sync daily";
      #   wantedBy = [ "timers.target" ];
      #   timerConfig = {
      #     OnCalendar = "daily";
      #     Persistent = true;
      #   };
      # };
      # Cấu hình samba
      services.samba = {
        enable = true;
        securityType = "user";
        openFirewall = true;
        settings = {
          global = {
            workgroup = "WORKGROUP";
            "server string" = "NixOS Samba Server";
            "netbios name" = "nixos-smb";
            security = "user";
            "guest account" = "nobody";
            "map to guest" = "Bad User";
          };
          public = {
            path = "/mnt/storage/public";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0664";
            "directory mask" = "0775";
            "force user" = "nobody";
            "force group" = "sambashare";
            # optional: ép quyền tạo file dưới user cụ thể
            # "force user" = "youruser";
            # "force group" = "yourgroup";
          };
          dd = {
            path = "/mnt/storage/dd";
            browseable = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "valid users" = "dd";
          };
        };
      };
      # users.users.sambauser = {
      #   isNormaluser = true;
      #   createHome = false;
      # };
      users.users.dd.extraGroups = [ "sambashare" ];
      users.groups.sambashare = { };
      services.avahi = {
        enable = true;
        publish.enable = true;
        publish.userServices = true;
        openFirewall = true;
      };
      services.samba-wsdd = {
        enable = true;
        openFirewall = true;
      };

      # bdx0.services.monit.enable = true;
      # bdx0.services.monit.address = "100.126.131.77";

      # services.rke2 = {
      #   enable = true;
      #   role = "server";
      #   configPath = config.age.secrets.goku01_rke2_config.path;
      #   debug = true;
      # };
      # environment.etc."/fuse.conf".text = ''
      #   user_allow_other
      #   mount_max = 1000
      # '';
    }
    (let iface = "enp1s0";
    in {
      # Enable networkd
      systemd.services."systemd-networkd-wait-online".enable =
        lib.mkForce false;
      systemd.network.enable = lib.mkForce true;
      systemd.network.wait-online.anyInterface = true;

      # Network .network config
      systemd.network.networks."10-${iface}" = {
        matchConfig.name = iface;
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = "routable";
      };

      # Recovery service triggered on link change
      systemd.services."net-recovery-${iface}" = let
        script = pkgs.writeShellScript "recovery-${iface}-script" ''
          # bring the interface up
          ${pkgs.iproute2}/bin/ip link set ${iface} down
          sleep 1
          ${pkgs.iproute2}/bin/ip link set ${iface} up
          # give DHCP a chance (if using DHCP)
          # sleep 1
          # ${pkgs.networkmanager}/bin/nmcli device reapply ${iface} || true
          ping -c3 -W2 8.8.8.8 || echo "Network still down"
        '';
      in {
        description = "Recover ${iface} and health-check";
        wants = [ "network-link-${iface}.service" ];
        after = [ "network-link-${iface}.service" ];

        # Run only when link goes DOWN
        # path = [ pkgs.iproute pkgs.networkmanager ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.iproute2 ];
        # serviceConfig.ExecStart = lib.concatStringsSep "\n" [
        #   "# bring the interface up"
        #   "${pkgs.iproute2}/bin/ip link set ${iface} down"
        #   # "sleep 1"
        #   "${pkgs.iproute2}/bin/ip link set ${iface} up"
        #   "# give DHCP a chance (if using DHCP)"
        #   # "sleep 1"
        #   # "${pkgs.networkmanager}/bin/nmcli device reapply ${iface} || true"
        # ];
        # serviceConfig.ExecStart = ''
        #   #!/user/bin/env bash -e
        #   # bring the interface up
        #   ${pkgs.iproute2}/bin/ip link set ${iface} down
        #   sleep 1
        #   ${pkgs.iproute2}/bin/ip link set ${iface} up
        #   # give DHCP a chance (if using DHCP)
        #   # sleep 1
        #   # ${pkgs.networkmanager}/bin/nmcli device reapply ${iface} || true
        # '';
        serviceConfig.ExecStart = "${script}";
      };

      # Health-check service to ping 8.8.8.8
      systemd.services."net-health-${iface}" = {
        description = "Ping check and recovery for ${iface}";
        wants = [ "net-recovery-${iface}.service" ];
        after = [ "net-recovery-${iface}.service" "network-online.target" ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.iproute2 ];
        # serviceConfig.ExecStart = lib.concatStringsSep "\n" [
        #   "ping -c 3 -W2 8.8.8.8 || systemctl start net-recovery-${iface}.service"
        # ];
        serviceConfig.ExecStart = ''
          ping -c 3 -W2 8.8.8.8 || systemctl start net-recovery-${iface}.service
        '';
      };

      # Timer to run health-check every minute
      systemd.timers."net-health-${iface}.timer" = {
        description = "Run net-health-${iface} every minute";
        timerConfig.OnCalendar = "*:0/5";
        wants = [ "net-health-${iface}.service" ];
      };
    })
  ];

}
