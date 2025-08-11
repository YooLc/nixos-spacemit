{
  description = "NixOS for SpaceMiT K1 products";
  inputs.nixpkgs.url = "github:YooLc/nixpkgs/nixos-25.05-small";

  outputs =
    { self, nixpkgs, ... }:
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
            };
          };
        }
      );
    };
}
