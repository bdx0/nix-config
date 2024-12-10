{ pkgs, inputs', ... }:
let
  nixos-aw = inputs'.nixos-anywhere;
  nixos-aw-pkg = nixos-aw.packages.default;
  inherit (pkgs)
    runCommand writeShellScriptBin writeScriptBin symlinkJoin writeText;
  sshScript = writeShellScriptBin "ssh" ''
    echo "ssh call"
    echo "$@"
    ${pkgs.openssh}/bin/ssh -F${sshConfig} $@
  '';
  sshpassScript = writeShellScriptBin "sshpass" ''
    echo "sshpass: $@"
    ${pkgs.openssh}/bin/sshpass $@
  '';
  sshcopyidScript = writeShellScriptBin "ssh-copy-id" ''
    echo "ssh-copy-id: $@"
    ${pkgs.openssh}/bin/ssh-copy-id $@
    echo $@
  '';
  sshConfig = writeText "ssh_config" ''
    Host freshHost
      HostName 192.168.110.4
      User root

    Host *
      LogLevel INFO

  '';
  freshInstallScript = writeShellScriptBin "freshInstallScript" ''
    echo "$@"
    # ls -la ${nixos-aw-pkg}/libexec/nixos-anywhere
    # ${nixos-aw-pkg}/libexec/nixos-anywhere/nixos-anywhere.sh --flake .#remoteInstall --build-on-remote "$@"
    ${nixos-aw-pkg}/bin/nixos-anywhere --flake .#remoteInstall --build-on-remote "$@"
  '';
  runtimeDeps =
    # [ freshInstallScript sshScript sshpassScript sshcopyidScript ];
    # [ freshInstallScript sshScript ];
    [ freshInstallScript ];
in {
  remoteInstall = symlinkJoin {
    # "https://ertt.ca/nix/shell-scripts/"
    name = freshInstallScript.name;
    paths = runtimeDeps;
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/${freshInstallScript.name} \
                    --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps} \
                    --suffix PATH : $out/bin'';
  };
  test = writeShellScriptBin "test" ''
    echo $@
  '';
  repair = writeShellScriptBin "repair" ''
    echo $@
    nix-store --verify --repair --check-contents
  '';
  default = pkgs.hello-unfree;
}
