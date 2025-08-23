{
  description = "NixOS for SpaceMiT K1 products";
  inputs.nixpkgs.url = "github:YooLc/nixpkgs/nixos-25.05-small";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  # Mesa 25.0.0 dropped libglapi.so, but we still need it
  inputs.nixpkgs-mesa.url = "github:NixOS/nixpkgs/bcad4f36b978bd56017dd57bfb71892ce9c9e959";

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-mesa,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system: {
        spacemit-toolchain = nixpkgs.legacyPackages.${system}.pkgs.callPackage ../spacemit-toolchain { };
        iso = self.nixosConfigurations.${system}.muse-pi-pro.config.system.build.isoImage;
        default = self.packages.${system}.iso;
      });

      hydraJobs = {
        iso = self.nixosConfigurations."x86_64-linux".muse-pi-pro.config.system.build.isoImage;
      };

      nixosConfigurations = forAllSystems (
        system:
        let
          crossBuild = {
            localSystem = "${system}";
            crossSystem = {
              config = "riscv64-unknown-linux-gnu";
              gcc.arch = "rv64gc";
              gcc.abi = "lp64d";
            };
          };
          crossBuildOpt = {
            localSystem = "${system}";
            crossSystem = {
              config = "riscv64-unknown-linux-gnu";
              gcc.arch = "rv64gc";
              gcc.abi = "lp64d";
            };
          };
          pkgs = import nixpkgs { };
          pkgs-mesa = import nixpkgs-mesa crossBuildOpt;
          pkgs-unstable = import nixpkgs-unstable crossBuildOpt;
          pkgs-cross = import nixpkgs crossBuild;
          pkgs-cross-opt = import nixpkgs crossBuildOpt;
        in
        {
          muse-pi-pro = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              (import ./module/cross.nix)
              (import ./module/iso-image.nix)
              (import ./module/muse-pi-pro.nix)
            ];
            specialArgs = {
              inherit pkgs-cross;
              inherit pkgs-cross-opt;
              inherit pkgs-unstable;
              inherit pkgs-mesa;
            };
          };
        }
      );
    };
}
