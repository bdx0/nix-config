{ config, lib, ... }:
let cfg = config.bdx0.services.monit;
in {
  options.bdx0.services.monit = {
    enable = lib.mkEnableOption "Enable Monit";
    address = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The address to bind the Monit HTTP server to";
    };
    allow_address = lib.mkOption {
      type = lib.types.str;
      default = "100.106.121.43";
      description = "The address to allow access to the Monit HTTP server";
    };
  };
  config = lib.mkIf cfg.enable {

    services.monit.enable = true;

    # "https://blog.vinahost.vn/cai-dat-cau-hinh-monit/"
    # "https://viblo.asia/p/gioi-thieu-ve-monit-cong-cu-giam-sat-server-manh-me-gAm5ybDXKdb"
    services.monit.config = ''
      set daemon 120
      set log /var/log/monit/monit.log
      set httpd port 2812 and
        use address ${config.bdx0.services.monit.address}
        allow ${config.bdx0.services.monit.allow_address}
        allow dd
    '';
  };
}
