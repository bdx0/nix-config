let
  authorizedKeys = builtins.fetchurl {
    url = "https://github.com/bdx0.keys";
    sha256 = "+J8afYYemnCTu0GKVOLpN+ArZOPy+pVmtR0HMPQ8vb8=";
  };
in builtins.split "\n" (builtins.readFile authorizedKeys)
