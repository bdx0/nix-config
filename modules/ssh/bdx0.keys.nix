let
  authorizedKeys = builtins.fetchurl {
    url = "https://github.com/bdx0.keys";
    sha256 = "+J8afYYemnCTu0GKVOLpN+ArZOPy+pVmtR0HMPQ8vb8=";
  };
  escape = list: builtins.replaceStrings list (map (c: "\\${c}") list);
  stringToCharacters = s:
    builtins.genList (p: builtins.substring p 1 s) (builtins.stringLength s);
  escapeRegex = escape (stringToCharacters "\\[{()^$?*+|.");
  addContextFrom = src: target: builtins.substring 0 0 src + target;
  splitString = sep: s:
    let
      splits = builtins.filter builtins.isString
        (builtins.split (escapeRegex (toString sep)) (toString s));
    in map (addContextFrom s) splits;
in splitString "\n" (builtins.readFile authorizedKeys)
