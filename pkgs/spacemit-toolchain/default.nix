{
  pkgs,
  lib,
  stdenv,
  fetchurl,
  ...
}:
stdenv.mkDerivation rec {
  pname = "spacemit-toolchain";
  version = "1.1.2";

  src = fetchurl {
    url = "https://archive.spacemit.com/toolchain/spacemit-toolchain-linux-glibc-x86_64-v${version}.tar.xz";
    sha256 = "sha256-N2DhRcEjG+mBEJeA0k9a074IdOXTSZIXW8bJey25XPM=";
  };

  buildPhase = ''
    mkdir -p $out
    tar -xvf $src --strip-components=1 -C $out

    # Remove broken symlinks
    rm $out/bin/gp-*
  '';

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
  ];

  meta = with lib; {
    description = "SpaceMiT cross-compilation toolchain";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
