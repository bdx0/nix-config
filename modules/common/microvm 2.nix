{ inputs, pkgs, lib, config, ... }:
let cfg = config.bdx0.server.microvm;
in {
  imports = [ inputs.microvm.nixosModules.host ];
  options.bdx0.server.microvm = {
    enable = lib.mkEnableOption "Enable MicroVM system";
  };
  config = lib.mkIf cfg.enable {
    microvm = {
      autostart = [ "test" "test2" ];
      vms = {
        rke2 = {
          autostart = true;
          inherit pkgs;
          specialArgs = { inherit inputs; };
          config = { pkgs, ... }: {
            imports = [
              inputs.self.nixosModules.common
              inputs.self.nixosModules.vm
              inputs.rke2.nixosModules.default
            ];
            #     # system.stateVersion = config.system.version;
            microvm = {
              mem = 8192;
              vcpu = 4;
              # cpu = "host";

              # ...add additional MicroVM configuration here
              # Use QEMU because nested virtualization and user networking are required.
              hypervisor = "qemu";
              # hypervisor = "kvmtool";
              interfaces = [{
                # type = "user";
                type = "tap";
                id = "vm-test2";
                mac = "02:00:00:00:00:01";
              }];
            };

            environment.systemPackages = with pkgs; [ lsof ];
            # Don't interfere with k8s
            networking.firewall.enable = lib.mkForce false;
            bdx0.container.engine = "docker";
            bdx0.libvirtd.enable = false;

            services.rke2 = {
              enable = true;
              role = "server";
              settings.tls-san =
                [ "lina" "lina.bdx0.io.vn" "rke2.lina.bdx0.io.vn" ];
              # extraFlags = [ "--disable" "rke2-ingress-nginx" ];
              # settings.kube-apiserver-arg = [ "anonymous-auth=false" ];
              # settings.tls-san = [ "<TODO>" ];
              # settings.write-kubeconfig-mode = "0644";
            };
            systemd.network.enable = true;
            networking.useNetworkd = true;
            networking.hostName = "rke2";
          };
        };
        rke2-agent01 = {
          autostart = true;
          inherit pkgs;
          specialArgs = { inherit inputs; };
          config = { pkgs, ... }: {
            imports =
              [ inputs.self.nixosModules.common inputs.self.nixosModules.vm ];
            #     # system.stateVersion = config.system.version;
            microvm = {
              mem = 4096;
              vcpu = 4;
              # cpu = "host";

              # ...add additional MicroVM configuration here
              # Use QEMU because nested virtualization and user networking are required.
              hypervisor = "qemu";
              # hypervisor = "kvmtool";
              interfaces = [{
                # type = "user";
                type = "tap";
                id = "vm-rke2-agent01";
                mac = "02:00:00:00:00:01";
              }];
            };

            environment.systemPackages = with pkgs; [ lsof ];
            # Don't interfere with k8s
            networking.firewall.enable = lib.mkForce false;
            bdx0.container.engine = "docker";
            bdx0.libvirtd.enable = false;

            services.rke2 = {
              enable = true;
              role = "agent";
              serverAddr = "https://rke2:9345";
            };
            systemd.network.enable = true;
            networking.useNetworkd = true;
            networking.hostName = "rke2-agent01";
          };
        };
        # test = {
        #   flake = inputs.self;
        #   updateFlake = "github:bdx0/nix-config?ref=mkOptions";
        # };
      };
    };
  };
}
