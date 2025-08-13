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
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (system: {
        spacemit-toolchain = nixpkgs.legacyPackages.${system}.pkgs.callPackage ../spacemit-toolchain { };
        iso = self.nixosConfigurations.${system}.muse-pi-pro.config.system.build.isoImage;
        default = self.packages.${system}.iso;
      });

      nixosConfigurations = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system}.pkgs.pkgsCross.riscv64;
          pkgs-mesa = nixpkgs-mesa.legacyPackages.${system}.pkgs.pkgsCross.riscv64;
          crossPkgs = pkgs.pkgsCross.riscv64;
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
              inherit crossPkgs;
              inherit pkgs-unstable;
              inherit pkgs-mesa;
            };
          };
        }
      );
    };
}
