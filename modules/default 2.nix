{
  common = import ./common;
  hosts = import ./hosts;
  disko = import ./disko.nix;
  colmena = import ./common/colmena.nix;
  containers = import ./containers;
}
