{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  name = "scripts";
  # "https://www.tweag.io/blog/2023-11-28-file-sets/"
  src = ./.;
  buildInputs = [ ];
  buildPhase = "";
  installPhase = ''
    mkdir -p $out/bin
    cp -rv $src/* $out/bin
    chmod +x $out/bin/*
  '';
  shellHook = ''
    set -o allexport; source .env; set +o allexport;
  '';
}
