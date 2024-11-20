{ disko, ... }: {
  imports = [
    #
    {
      nixpkgs.config = {
        allowBroken = true;
        allowUnfree = true;
        unfreeRedistributable = _: true;
      };
    }
    disko.nixosModules.disko
    ../../modules/vm/disko.nix
    ./configuration.nix
  ];
}
