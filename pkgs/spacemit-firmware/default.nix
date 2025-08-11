{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "spacemit-firmware";
  version = "2.2";

  src = fetchGit {
    url = "https://gitee.com/bianbu-linux/buildroot-ext.git";
    rev = "22a008dfba8b8b4c3b7783e8e6427ba8e76ec467";
  };

  buildCommand = ''
    mkdir -p $out/lib/firmware
    cp -r $src/board/spacemit/k1/target_overlay/lib/firmware/* $out/lib/firmware
  '';
}
