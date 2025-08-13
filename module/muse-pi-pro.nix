{
  pkgs,
  crossPkgs,
  lib,
  modulesPath,
  pkgs-unstable,
  pkgs-mesa,
  ...
}:
let
  spacemit-firmware = crossPkgs.callPackage ../pkgs/spacemit-firmware { };
  spacemit-mesa = crossPkgs.callPackage ../pkgs/spacemit-mesa { inherit pkgs-mesa; };
  spacemit-img-gpu-powervr = crossPkgs.callPackage ../pkgs/spacemit-img-gpu-powervr {
    inherit spacemit-mesa;
  };
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
      package = spacemit-mesa;
      extraPackages = [
        (lib.lowPrio pkgs-mesa.mesa.drivers)
        spacemit-img-gpu-powervr
      ];
    };
  };

  environment.etc = {
    "powervr.ini".source = "${spacemit-img-gpu-powervr}/etc/powervr.ini";
    "OpenCL/vendors/IMG.icd".source = "${spacemit-img-gpu-powervr}/etc/OpenCL/vendors/IMG.icd";
    "vulkan/icd.d/powervr_icd.json".source =
      "${spacemit-img-gpu-powervr}/etc/vulkan/icd.d/powervr_icd.json";
  };

  environment.systemPackages =
    with pkgs;
    [
      # Utilities
      vim
      git
      wget
      gcc
      btop
      strace

      # Meta Info
      nix-info
      fastfetch

      # Graphics
      glmark2
      glxinfo
      xwayland
      xwayland-satellite
    ]
    ++ [
      pkgs-unstable.vulkan-tools
    ];

  # Desktop
  programs.sway.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  environment.variables = {
    MESA_LOADER_DRIVER_OVERRIDE = "pvr";
    GALLIUM_DRIVER = "pvr";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  system.stateVersion = "25.05";
}
