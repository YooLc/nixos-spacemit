{
  pkgs,
  pkgs-mesa,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "24.01";
  revision = "bb2";
  # https://bianbu-linux.spacemit.com/en/graphics/graphics_driver_framework/
  libegl1-mesa = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libegl1-mesa_${version}-${revision}_riscv64.deb";
    hash = "sha256-V1EwloPFZRx34bkd6jPcxtjk6OP4ZEAto1jh/E3leC8=";
  };
  libglapi-mesa = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libglapi-mesa_${version}-${revision}_riscv64.deb";
    hash = "sha256-ZBbdSlpRmcj+/Pn+yPZJ9kaXrEENK/mBI4iWvz9qi2s=";
  };
  libgbm1 = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libgbm1_${version}-${revision}_riscv64.deb";
    hash = "sha256-pwbf2KjCoGwoS7iYbLJ5cKE096T6yo9NCfTsoEcjfRI=";
  };
  libegl-mesa0 = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libegl-mesa0_${version}-${revision}_riscv64.deb";
    hash = "sha256-K6XGqKPBqxXNn3EfHktPuiXRzJhyvmlBtgtXkM189L0=";
  };
  libgles2-mesa = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libgles2-mesa_${version}-${revision}_riscv64.deb";
    hash = "sha256-L/ybcAi/gjVVuX/ByFs9pdTzdv8udCDxQJVY02wj6VQ=";
  };
  libgl1-mesa-glx = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libgl1-mesa-glx_${version}-${revision}_riscv64.deb";
    hash = "sha256-9s0vcbuoVmWMZLfGCuc8dTIU5oLbz1wlbIWYKKVGtho=";
  };
  libglx-mesa0 = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libglx-mesa0_${version}-${revision}_riscv64.deb";
    hash = "sha256-P8NtROyzlN9xcM2wleThccwm70/mFS8nVepVs4/k7IY=";
  };
  libosmesa6 = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libosmesa6_${version}-${revision}_riscv64.deb";
    hash = "sha256-NSD32QBO2/gYSz6mZNdTtJBrtfIwcMBS4aCOB9pi8vI=";
  };
  libwayland-egl1-mesa = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libwayland-egl1-mesa_${version}-${revision}_riscv64.deb";
    hash = "sha256-gMlvhuLwCyU4IzFdbQZWA27LWObIC6+A7wlaR+46WRo=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "spacemit-mesa";
  inherit version revision;

  inherit
    libegl1-mesa
    libglapi-mesa
    libgbm1
    libegl-mesa0
    libgles2-mesa
    libgl1-mesa-glx
    libglx-mesa0
    libosmesa6
    libwayland-egl1-mesa
    ;

  src = fetchurl {
    url = "https://archive.spacemit.com/bianbu/pool/main/m/mesa/libgl1-mesa-dri_${version}-${revision}_riscv64.deb";
    hash = "sha256-SXnZ6C3PaeL6BNl4kEm9ZtLRov8nFIjIOgwVpMTjjvs=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = with pkgs; [
    libdrm.out
    zlib.out
    zstd.out
    expat.out
    xorg.libxcb.out
    xorg.libXfixes.out
    xorg.libxshmfence.out
    xorg.libXext.out
    xorg.libXxf86vm.out
    libgcc.out
    kdePackages.wayland.out
    stdenv.cc.cc.lib
  ];
  # ++ [ pkgs-mesa.mesa.drivers ];

  unpackPhase = ''
    dpkg -x ${libegl1-mesa} unpack
    dpkg -x ${libglapi-mesa} unpack
    dpkg -x ${libgbm1} unpack
    dpkg -x ${libegl-mesa0} unpack
    dpkg -x $src unpack
    dpkg -x ${libgles2-mesa} unpack
    dpkg -x ${libgl1-mesa-glx} unpack
    dpkg -x ${libglx-mesa0} unpack
    dpkg -x ${libosmesa6} unpack
    dpkg -x ${libwayland-egl1-mesa} unpack
  '';

  installPhase = ''
    mkdir -p $out
    mkdir -p $out/lib
    mkdir -p $out/share

    cp -r unpack/* $out/
    cp -r unpack/usr/lib/* $out/lib/
    cp -r unpack/usr/share/* $out/share/
    mv $out/lib/riscv64-linux-gnu/* $out/lib

    rm -r $out/lib/riscv64-linux-gnu
    rm -r $out/usr
  '';
}
