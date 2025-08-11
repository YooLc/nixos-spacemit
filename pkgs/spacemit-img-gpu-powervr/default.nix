{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "spacemit-img-gpu-powervr";
  version = "2.2";

  src = fetchGit {
    url = "https://gitee.com/bianbu-linux/img-gpu-powervr.git";
    rev = "dbbd7d7fbefe627e5e544cdbcb7a5e202f69a679";
  };

  buildCommand = ''
    mkdir -p $out/lib/firmware
    cp -r $src/target/lib/firmware/* $out/lib/firmware
  '';
}
