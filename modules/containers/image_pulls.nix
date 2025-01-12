{ dockerTools }:
let
  ubuntu = dockerTools.pullImage {
    imageName = "ubuntu";
    imageDigest =
      "sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab";
    sha256 = "hNBzx8206/QvliFCCAGv+3/dsZWCJiQqikxi6ouAycE=";
    finalImageName = "ubuntu";
    finalImageTag = "latest";
  };
  fedora = dockerTools.pullImage {
    imageName = "fedora";
    imageDigest =
      "sha256:3ec60eb34fa1a095c0c34dd37cead9fd38afb62612d43892fcf1d3425c32bc1e";
    sha256 = "WG1GoK0oB9nbn079RMO19lOjuH2HTJ2WySm7mnQ2+WY=";
    finalImageName = "fedora";
    finalImageTag = "latest";
  };
  cuda = dockerTools.pullImage {
    imageName = "nvidia/cuda";
    imageTag = "latest";
    imageDigest =
      "sha256:40042016a816cbbe0504dd0a396e7cfc036a8aa43f5694af60dd6f8f87d24e52";
    sha256 = "";
  };
  alpine = dockerTools.pullImage {
    imageName = "alpine";
    imageTag = "latest";
    imageDigest = "";
    sha256 = "";
  };
  postgres = dockerTools.pullImage {
    imageName = "postgres";
    imageDigest =
      "sha256:bab8d7be6466e029f7fa1e69ff6aa0082704db330572638fd01f2791824774d8";
    sha256 = "o7pGwQ6h8xCU65spDDP6DG1oLcN2rSrW05gACeJK6Q8=";
    finalImageName = "postgres";
    finalImageTag = "15.0";
  };

in { inherit ubuntu fedora cuda alpine postgres; }
