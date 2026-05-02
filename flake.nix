{
  description = "Flake for some utilities related to running NixOS on the Odroid C4 SBC";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages."${system}";
      pkgsCross = pkgs.pkgsCross.aarch64-multiplatform;

      meson64-tools = pkgs.callPackage ./uboot/meson64-tools.nix { };
      firmwareOdroidC4 = pkgsCross.callPackage ./uboot/hardkernel-firmware.nix { };
      uboot = pkgsCross.callPackage ./uboot { inherit meson64-tools firmwareOdroidC4; };
    in
    {
      packages."${system}" = {
        inherit meson64-tools firmwareOdroidC4 uboot;
      };
    };
}
