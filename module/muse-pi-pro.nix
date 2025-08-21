{
  pkgs-cross,
  pkgs-cross-opt,
  pkgs-unstable,
  pkgs-mesa,
  lib,
  modulesPath,
  ...
}:
let
  # Spacemit Vendor Kernel (6.6.63)
  kernelDrv = pkgs-cross.callPackage ../pkgs/kernel { };
  kernelPkg = pkgs-cross.linuxPackagesFor kernelDrv;
  # Spacemit Vendor Firmware
  spacemit-firmware = pkgs-cross-opt.callPackage ../pkgs/spacemit-firmware { };
  spacemit-mesa = pkgs-cross-opt.callPackage ../pkgs/spacemit-mesa { inherit pkgs-mesa; };
  spacemit-img-gpu-powervr = pkgs-cross-opt.callPackage ../pkgs/spacemit-img-gpu-powervr {
    inherit spacemit-mesa;
  };
in
{
  boot = {
    kernelPackages = kernelPkg;
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
    # Print boot log to external monitor
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
    "glvnd/egl_vendor.d/50_mesa.json" = {
      text = ''
        {
            "file_format_version" : "1.0.0",
            "ICD" : {
                "library_path" : "/run/opengl-driver/lib/libEGL_mesa.so.0"
            }
        }
      '';
      mode = "0444";
    };
  };

  environment.systemPackages =
    with pkgs-cross-opt;
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
      egl-wayland
      libGL
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
    MESA_LOADER_DRIVER_OVERRIDE = "zink";
    GALLIUM_DRIVER = "zink";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };

  system.stateVersion = "25.05";
}
