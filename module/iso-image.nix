{
  lib,
  crossPkgs,
  modulesPath,
  ...
}:
let
  # Spacemit Vendor Kernel (6.6.63)
  kernelDrv = crossPkgs.callPackage ../pkgs/kernel { };
  kernelPkg = crossPkgs.linuxPackagesFor kernelDrv;
in
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.kernelPackages = kernelPkg;

  # Needed for mounting stage 2 filesystems
  boot.initrd.kernelModules = [
    "iso9660"
    "squashfs"
  ];

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    # Prebuilt efi.img as GRUB2 from nixpkgs has 'relocation overflow'
    contents = [
      {
        source = ./prebuilt/efi.img;
        target = "/boot/efi.img";
      }
    ];
  };

  nixpkgs.overlays = [
    (import ../overlay/grub2.nix)
  ];
}
