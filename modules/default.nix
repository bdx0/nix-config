{
  common = import ./common;
  lib = import ./lib;
  hosts = import ./hosts;
  disko = import ./disko.nix;
  colmena = import ./common/colmena.nix;
  containers = import ./containers;
}
