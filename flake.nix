{
  description = "Flake for some utilities related to running NixOS on the Odroid C4 SBC";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-old.url = "github:nixos/nixpkgs/e0169d7a9d324afebf5679551407756c77af8930";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-old,
    }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages."${system}";
      pkgsCross = pkgs.pkgsCross.aarch64-multiplatform;

      meson64-tools = pkgs.callPackage ./uboot/meson64-tools.nix { };

      # Use legacy nixpkgs for gcc49 to build the firmware.
      pkgsOld = nixpkgs-old.legacyPackages."${system}";
      pkgsCrossOld = pkgsOld.pkgsCross.aarch64-multiplatform;
      firmwareOdroidC4 = pkgsCrossOld.callPackage ./uboot/hardkernel-firmware.nix { };

      uboot = pkgsCross.callPackage ./uboot { inherit meson64-tools firmwareOdroidC4; };
    in
    {
      packages."${system}" = {
        inherit meson64-tools firmwareOdroidC4 uboot;
      };
    };
}
