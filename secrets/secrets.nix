let
  dd = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCiuM0LPeQ/A+R1zBTsMOlEyLl7KjeSFVXFpn9cqHll3yJRwo+f7s8foROFyj6qZJNAljCz6PoQrVaiTOsafKOlvKw4THCss9sikDFWN24XZ99FjljNW1rPMyhsdOjArxkT4OUyakytVMlMNMZOAG0zg8ZP1qYXR2UJhDUxJDsd/oCG5TxFVosBm+eKUDty9yfeIh7FrsO0c73jVVb8TkicXdpZTifebYCd3NQBmaP5JDmhA4wTMVfXKHC/8radKWAcZBWt+68zzRwDJH6/BLN6s3y3WygJ6X1XNSBMDDSo6YPY8erqNQ2Klvd3lTDC8IG9thvdZVAQqx7yYt8geERzwfPki6e8lMFnykd0mWXqSRirkkW31LyZ4DgWBQ/BIDuqzdOdCKowAjRvBCxTB9IW9uE15X1tgLa+AiEBDU9WlXO/F0+GK5Wi3NZVPjXhCWIvUXDt8FeCEQAbB1lzuFrgO1e0R0I+0gpHW9+i/zgcdyNp9WSvigE54g54MpzZbOAnMMaC5680uBxzahr3ylQYeYe1yLQNoVrX5Y7Fmb0TILZssyc4Wxgk6TS06U/NqYB1hGfJ19Y0mUV/icpyvV/3+UxtpM7IiKl3pb3wdNYQLLxbN9Db4H9glrxeOLX3aAduo90qHrpnSVOzWju+jAQpd/TrPipFDTjO2uGzjb9gNw== duydb2@gmail.com
  '';
  lina =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJqa/VEDPOqNyBnrm91jSGDMZ8VbbKSqqB4+oojcmZi";
  bobo =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJqa/VEDPOqNyBnrm91jSGDMZ8VbbKSqqB4+oojcmZi";
  goku =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGJqa/VEDPOqNyBnrm91jSGDMZ8VbbKSqqB4+oojcmZi";
in {
  "pgadmin.age".publicKeys = [ dd lina ];
  "rke2_config.age".publicKeys = [ dd lina ];
}
