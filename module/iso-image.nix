{
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

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
