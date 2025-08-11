{
  stdenv,
  lib,
  fetchFromGitHub,
  buildLinux,
  ...
}@args:

let
  modDirVersion = "6.6.63";
in
lib.overrideDerivation
  (buildLinux (
    args
    // {
      version = "${modDirVersion}";
      inherit modDirVersion;
      pname = "linux-spacemit";

      src = fetchGit {
        url = "https://gitee.com/bianbu-linux/linux-6.6.git";
        rev = "cecd843d17630cdab0df49d709ea5ab37e3a5fce";
      };

      defconfig = "k1_defconfig";
      enableCommonConfig = false;
      autoModules = false;

      # To match vendor config
      structuredExtraConfig = with lib.kernel; {
        IMAGE_LOAD_OFFSET = freeform "0x200000";
      };
    }
    // (args.argsOverride or { })
  ))
  (oldAttrs: {
    # Don't use build/ dir because SpaceMiT include some out-of-tree
    # modules that don't respect to the build dir setting
    patches = [ ];
    configurePhase = ''
      runHook preConfigure
      export buildRoot="$(pwd)"

      echo "manual-config configurePhase buildRoot=$buildRoot pwd=$PWD"

      if [ -f "$buildRoot/.config" ]; then
        echo "Could not link $buildRoot/.config : file exists"
        exit 1
      fi
      ln -sv ${oldAttrs.configfile} $buildRoot/.config

      # reads the existing .config file and prompts the user for options in
      # the current kernel source that are not found in the file.
      make $makeFlags "''${makeFlagsArray[@]}" oldconfig
      runHook postConfigure

      make $makeFlags "''${makeFlagsArray[@]}" prepare
      actualModDirVersion="$(cat $buildRoot/include/config/kernel.release)"
      if [ "$actualModDirVersion" != "${modDirVersion}" ]; then
        echo "Error: modDirVersion ${modDirVersion} specified in the Nix expression is wrong, it should be: $actualModDirVersion"
        exit 1
      fi

      buildFlagsArray+=("KBUILD_BUILD_TIMESTAMP=$(date -u -d @$SOURCE_DATE_EPOCH)")

      cd $buildRoot
    '';
    postInstall = ''
      mkdir -p $dev
      cp vmlinux $dev/
      if [ -z "''${dontStrip-}" ]; then
        installFlagsArray+=("INSTALL_MOD_STRIP=1")
      fi
      make modules_install $makeFlags "''${makeFlagsArray[@]}" \
        $installFlags "''${installFlagsArray[@]}"
      unlink $out/lib/modules/${modDirVersion}/build
      rm -f $out/lib/modules/${modDirVersion}/source

      mkdir -p $dev/lib/modules/${modDirVersion}/{build,source}

      rsync -a -L $buildRoot/ $dev/lib/modules/${modDirVersion}/source/

      cd $dev/lib/modules/${modDirVersion}/source
      make mrproper ARCH=riscv

      cp $buildRoot/{.config,Module.symvers} $dev/lib/modules/${modDirVersion}/build
      make modules_prepare $makeFlags "''${makeFlagsArray[@]}" O=$dev/lib/modules/${modDirVersion}/build

      # For reproducibility, removes accidental leftovers from a `cc1` call
      # from a `try-run` call from the Makefile
      rm -f $dev/lib/modules/${modDirVersion}/build/.[0-9]*.d

      # Keep some extra files on some arches (powerpc, aarch64)
      for f in arch/powerpc/lib/crtsavres.o arch/arm64/kernel/ftrace-mod.o; do
        if [ -f "$buildRoot/$f" ]; then
          cp $buildRoot/$f $dev/lib/modules/${modDirVersion}/build/$f
        fi
      done

      # !!! No documentation on how much of the source tree must be kept
      # If/when kernel builds fail due to missing files, you can add
      # them here. Note that we may see packages requiring headers
      # from drivers/ in the future; it adds 50M to keep all of its
      # headers on 3.10 though.

      chmod u+w -R ..
      arch=$(cd $dev/lib/modules/${modDirVersion}/build/arch; ls)

      # Remove unused arches
      for d in $(cd arch/; ls); do
        if [ "$d" = "$arch" ]; then continue; fi
        if [ "$arch" = arm64 ] && [ "$d" = arm ]; then continue; fi
        rm -rf arch/$d
      done

      # Remove all driver-specific code (50M of which is headers)
      rm -fR drivers

      # Keep all headers
      find .  -type f -name '*.h' -print0 | xargs -0 -r chmod u-w

      # Keep linker scripts (they are required for out-of-tree modules on aarch64)
      find .  -type f -name '*.lds' -print0 | xargs -0 -r chmod u-w

      # Keep root and arch-specific Makefiles
      chmod u-w Makefile arch/"$arch"/Makefile*

      # Keep whole scripts dir
      chmod u-w -R scripts

      # Delete everything not kept
      find . -type f -perm -u=w -print0 | xargs -0 -r rm

      # Delete empty directories
      find -empty -type d -delete
    '';
  })
