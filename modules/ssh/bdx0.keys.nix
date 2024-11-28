{ pkgs, ... }:
let authorizedKeys = pkgs.fetchurl { url = "https://github.com/bdx0.keys"; };
in pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys)
