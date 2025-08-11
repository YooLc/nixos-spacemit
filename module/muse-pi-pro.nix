{
  pkgs,
  crossPkgs,
  lib,
  modulesPath,
  ...
}:
let
  spacemit-firmware = crossPkgs.callPackage ../pkgs/spacemit-firmware { };
  spacemit-img-gpu-powervr = crossPkgs.callPackage ../pkgs/spacemit-img-gpu-powervr { };
in
{
  boot = {
    initrd = {
      includeDefaultModules = false;
      availableKernelModules = lib.mkForce [
        "ext4"
        "sd_mod"
        "mmc_block"
        "spi_nor"
        "xhci_hcd"
        "usbhid"
        "hid_generic"
        "loop"
        "overlay"
        "nvme"
        "8852bs"
      ];
    };
    supportedFilesystems = lib.mkForce [
      "vfat"
      "ext4"
      "btrfs"
    ];
    kernelParams = [ "console=tty1" ];
    # Wireless
    kernelModules = [ "8852bs" ];
  };

  # Firmware
  hardware = {
    firmware = [
      spacemit-firmware
      spacemit-img-gpu-powervr
    ];
    firmwareCompression = "none";
  };

  boot.initrd.extraFirmwarePaths = [
    # https://bianbu-linux.spacemit.com/en/faqs/
    "esos.elf"
    # GPU firmware
    "rgx.fw.36.29.52.182"
    "rgx.sh.36.29.52.182"
  ];

  hardware = {
    deviceTree = {
      enable = true;
      name = "spacemit/k1-x_MUSE-Pi-Pro.dtb";
    };
    graphics = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Utilities
    vim
    git
    wget
    gcc
    btop

    # Meta Info
    nix-info
    fastfetch

    # Graphics
    mesa
    glmark2
    glxinfo
  ];

  # Desktop
  programs.sway.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
