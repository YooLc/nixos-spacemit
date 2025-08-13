{
  pkgs,
  stdenvNoCC,
  fetchurl,
  spacemit-mesa,
}:

stdenvNoCC.mkDerivation rec {
  pname = "spacemit-img-gpu-powervr";
  version = "24.2";
  revision = "6603887bb8";

  src = fetchTarball {
    url = "https://archive.spacemit.com/bianbu/pool/main/i/img-gpu-powervr-cloud/img-gpu-powervr-cloud_${version}-${revision}.tar.xz";
    sha256 = "sha256:1yzphiyqqm4wkigbzkkqi56qv9m7dly9c5cf2fj95vygljidsl0f";
  };

  buildInputs = with pkgs; [
    libdrm.out
    zlib.out
    expat.out
    libgcc.out
    kdePackages.wayland.out
    stdenv.cc.cc.lib
    spacemit-mesa
    libGL.out
    eudev.out
  ];

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    tree
  ];

  installPhase = ''
    mkdir -p $out/etc
    mkdir -p $out/lib
    mkdir -p $out/bin
    mkdir -p $out/share

    cp -r $src/target/etc $out
    cp -r $src/target/lib $out
    cp -r $src/target/usr/lib $out
    cp -r $src/target/usr/share $out
    cp -r $src/target/usr/local/lib $out
    cp -r $src/target/usr/local/share $out
    cp -r $src/target/usr/local/bin $out
  '';
}
