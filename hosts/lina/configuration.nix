{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/common.nix

  ];
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables =
    true; # config with efiInstallAsRemovable = true
  boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.devices = [ "/dev/sdb" "/dev/sda" ];
  boot.loader.grub.useOSProber = true;

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.hostName = "lina";
  networking.domain = "lina.bdx0.io.vn";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiuM0LPeQ/A+R1zBTsMOlEyLl7KjeSFVXFpn9cqHll3yJRwo+f7s8foROFyj6qZJNAljCz6PoQrVaiTOsafKOlvKw4THCss9sikDFWN24XZ99FjljNW1rPMyhsdOjArxkT4OUyakytVMlMNMZOAG0zg8ZP1qYXR2UJhDUxJDsd/oCG5TxFVosBm+eKUDty9yfeIh7FrsO0c73jVVb8TkicXdpZTifebYCd3NQBmaP5JDmhA4wTMVfXKHC/8radKWAcZBWt+68zzRwDJH6/BLN6s3y3WygJ6X1XNSBMDDSo6YPY8erqNQ2Klvd3lTDC8IG9thvdZVAQqx7yYt8geERzwfPki6e8lMFnykd0mWXqSRirkkW31LyZ4DgWBQ/BIDuqzdOdCKowAjRvBCxTB9IW9uE15X1tgLa+AiEBDU9WlXO/F0+GK5Wi3NZVPjXhCWIvUXDt8FeCEQAbB1lzuFrgO1e0R0I+0gpHW9+i/zgcdyNp9WSvigE54g54MpzZbOAnMMaC5680uBxzahr3ylQYeYe1yLQNoVrX5Y7Fmb0TILZssyc4Wxgk6TS06U/NqYB1hGfJ19Y0mUV/icpyvV/3+UxtpM7IiKl3pb3wdNYQLLxbN9Db4H9glrxeOLX3aAduo90qHrpnSVOzWju+jAQpd/TrPipFDTjO2uGzjb9gNw== duydb2@gmail.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiuM0LPeQ/A+R1zBTsMOlEyLl7KjeSFVXFpn9cqHll3yJRwo+f7s8foROFyj6qZJNAljCz6PoQrVaiTOsafKOlvKw4THCss9sikDFWN24XZ99FjljNW1rPMyhsdOjArxkT4OUyakytVMlMNMZOAG0zg8ZP1qYXR2UJhDUxJDsd/oCG5TxFVosBm+eKUDty9yfeIh7FrsO0c73jVVb8TkicXdpZTifebYCd3NQBmaP5JDmhA4wTMVfXKHC/8radKWAcZBWt+68zzRwDJH6/BLN6s3y3WygJ6X1XNSBMDDSo6YPY8erqNQ2Klvd3lTDC8IG9thvdZVAQqx7yYt8geERzwfPki6e8lMFnykd0mWXqSRirkkW31LyZ4DgWBQ/BIDuqzdOdCKowAjRvBCxTB9IW9uE15X1tgLa+AiEBDU9WlXO/F0+GK5Wi3NZVPjXhCWIvUXDt8FeCEQAbB1lzuFrgO1e0R0I+0gpHW9+i/zgcdyNp9WSvigE54g54MpzZbOAnMMaC5680uBxzahr3ylQYeYe1yLQNoVrX5Y7Fmb0TILZssyc4Wxgk6TS06U/NqYB1hGfJ19Y0mUV/icpyvV/3+UxtpM7IiKl3pb3wdNYQLLxbN9Db4H9glrxeOLX3aAduo90qHrpnSVOzWju+jAQpd/TrPipFDTjO2uGzjb9gNw== duydb2@gmail.com"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrSYLQRu47UslqXlepgIFrSKTtyugJ+wk7rGvoBuvqsuYarkKKma7SgZ9/eA0L5uCRAyKvpHPe99akkeLvuAIUKX9dw/zJUUjVtGPUTeAeJwWNzbLdWdxbFfnJVsmMdqNTJAW4YpECulZadFzlJxYjjVL8RXeYj2looiOY7VO5mZz7VGUBYTfeNyrIGP5LcVufM4o2bzsGqRvOyWIvtKFZgpXjUtKTuL8Ye6rWKThRJrRSKH6XGQV+woPwAn4WW2Y7jjO5j+i6EfKxxvRdINhTVL9i0KdajsytbmJ6OYdpP87jb9dD7UG7ANdL7HRPQszKPa+AIy9kc7tVN10dB/7CpOwkwAJclSIhhlW94EWsJnnMjhtykac56L3l7DsXnnBZJbtIDu6dQTf0LSnSWUKfBi+poeZ6P4ZZd4/TO/kOi0ua9A3OkwZwPiZjow4CZBVk8HjKRBtHVAOcVgaB08V/luc53ofyRBR0cSCNfLwEgMZ3N8l9bo5bEcHPzDNZsA2NqcSFmGL1WBUu3vXc6i2RY/Kk4YwibWQCmuNKdOHDn0Tlxhhiklu0LNmP9trAGLyqFaOGe0ETEAvHisVg4vz7cmLLk7b5ONxMPdBQbmFl9rXOrxQaWyJWrbQMUMMwmlVQ4OJJvJmzFJAPcuWhlrPAjGsrVUaO01uaonXM4Wvv9Q== bdx0@github/39885438 # ssh-import-id gh:bdx0"
    ""
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3e4Hp/iSt+Faf1DRFOm1UKJHL0oG8JCl/pFyJNrEs35gl7mnTf9CP8dFOTC32qvIA6WiX8fVpj2x5CxSCZ3LK3VVblPoXTx/Yj2/a9FCASEjMaXqojMf/k3c2V1H1Cvo4BDPB+RVciBBLnEMg+CqHaygaX4+HVxdbJTwMPPhwL5yI0Ih1nJLsyhoDhBbvl6Dux0M4WAby58oA5uxxU8oQAstIx3Qrox/yqs+3sG1ZQmkN/nOw5cRo2x54MIUE//KDhxQbgY7Rxyks3T73X3JxX5I24Odyub+T+lHMkg+wY5PqPzP+j59Kn2dJAbA5bdPOll94qNKUdMIxY2XpsPSYZz+BcMultVoCgjoH+BE0qrsitJVCzyXXvTeSLBVl7K5C8pK1wbSuVtZV57vzTjmUxo/Hzicg9Uj1FHu967f4MnwGFYdiH9iBTgsvzauwkqpWYjeAfninfGI9O6jAIeXOa1DxspH/BcPbj9PhOWEuWPZXXGcE+KBodf9tHoNPhmK1jmv6zbARmFHlTpm+9wlpqCzLCjTaQZ/Z7kyyleF+ibi3ZyBNNZoznFBlPZmpHkbXZEjdKLE2ZU755t+BioSIxaj6sISVKRsXGC2++RaTzbherv/s1gTzHlk/vO51bT9pAnBivHFQ6MVom2Jp2qNpzp/0NrmnKgoyEAqvC/KDBQ== bdx0@github/85930518 # ssh-import-id gh:bdx0"
    ""
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCfIkX680yzYWqLD331ortr9vMPrDRgH2mLPqeUr/8/aKUc0gM4KzgdNa9n/AtEqUsWKhTDmVFQwmzKjHi+qG7onx4NcOOXFYFYnZ4IFLsUmFt2VIcbvf95SW9HbP/9SNonE83CM7nOijKNlDi9U/czQ3fnaw4j71QZ4MF0CSXaHsMEnlC+vNkR8voMrLTsf2m+uBTNr3LLxEfm+1qsHOgEFpUA0rpK+iicF8yrQh7nj//MTMShWb8IYG6Z5u0OkcMAN9Zup0OObyCZdSoyDwmSRiAMLjwl37bkrJg1bHKIQ9WhpyPhwwIkzPW/dyjApMOtkRMj3i+U8pstoEwNF64opFc75Cxd6QCfRsswyR226qoAmZFd/d98Gq59IDMkZ79L98cx4LePNGC04sQ3BwgMjsWZ4dXAk8Zou5MciU2e4cShRx6jL8w6OHgOMhB17+VWuNHKzBbEZ69N2DG81RuRGVbRCANwR/czoWmgSliObkYP/kGvh96huv8VLzbMni8xOKiMPrA2zB8HHbeqr/Mg0qzCnOMCHqT4F64wlkfJQMCZMyikhCg9Igty+VlUghzieJ+/Qmpg8SNF1AO9Wd9k31Hm01SU9pCm6fR8Na1/Nz08/i7SD3m20396C38KL2mpXDtpodjC89SzpJrxHKdU/Oz7jMalvXH2kogip7ud+Q== bdx0@github/86386885 # ssh-import-id gh:bdx0"
    ""
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDUd4WKx61EjXHXcxQ4REJeBaPCCVnu6pFKhNVJFPKCDf/5boYmMVucufgLWwEzST4leFTygus4ibo/Hk35ibB8sdwDwLJ7zu+Nit7YqLqyf9KitoB/+aGBU0kVAUp6vxTWPcdZbHKr8Yx1r/pLqk0lIuCy1YrEQjFLIAx6X/xO73BvVAIBcrCSsxJWxv040Bl/a8kuxZQZv1QpqfXsZYnPTqv+zj8Y6m35qeCYr/9td+sAKl9CbRmyIu5YIx6Mnd5vGQxe6pl0Ux2s1kwo+MOzD0DhzuUiFOsMPfo9/bv/sqi0JW/UrYlxKQ9Vcg79zFTfj1ATeGUX4hO7ox7ZR4oJzSxd5UF/SaN4rncOFLLkBUupHHAgiBFxqD2+jIDrGQVxLENJEz1GVPwZTjetJWZlhEBtMtnKYDWwnsr1UusZzhBf6qPOS2zAGv17z0QYRcpRQNodeEQv6SaaWovuTCEM1oQgmfcEG1Td+GNe8fOAwQPLumk1YVrQbUFx4LrElVc= bdx0@github/96677172 # ssh-import-id gh:bdx0"
  ] ++ import ../../modules/ssh/bdx0.keys.nix;
  users.defaultUserShell = pkgs.bash;
  programs.bash.interactiveShellInit = ''figurine -F "3d.flf" nix-infect'';
  environment.systemPackages = with pkgs; [ wget figurine cmatrix ];
}
