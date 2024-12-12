{
  homelab-0 = import ./homelab.nix;
  homelab-1 = import ./homelab.nix;
  homelab-2 = import ./homelab.nix;
  basic = ({ inputs, ... }: {
    imports = [
      inputs.nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./facter.json; }
    ];
  });
  remoteInstall = { imports = [ ./hosts/freshHost ]; };
  lina = { imports = [ ./hosts/lina ]; };
  test = { inputs, lib, ... }: {
    imports = [
      inputs.microvm.nixosModules.microvm
      inputs.self.nixosModules.common
      inputs.self.nixosModules.vm
      {
        imports = [ inputs.rke2.nixosModules.default ];
        microvm = {
          # ...add additional MicroVM configuration here
          interfaces = [{
            # type = "user";
            type = "tap";
            id = "vm-test";
            mac = "02:00:00:00:00:01";
          }];
        };

        # Don't interfere with k8s
        networking.firewall.enable = lib.mkForce false;

        services.rke2 = {
          enable = true;
          role = "server";
          extraFlags = [ "--disable" "rke2-ingress-nginx" ];
          # settings.kube-apiserver-arg = [ "anonymous-auth=false" ];
          # settings.tls-san = [ "<TODO>" ];
          # settings.write-kubeconfig-mode = "0644";
        };

        networking.useNetworkd = true;
        networking.hostName = "test";
        users.users.root.password = "testtest";
        nixpkgs.config.allowUnfree = true;
      }
    ];
  };
}
