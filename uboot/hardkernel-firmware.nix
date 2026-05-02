#Original source:
#https://github.com/samueldr/nixpkgs/blob/wip/odroidc4/pkgs/misc/uboot/hardkernel-firmware.nix
{
  stdenv,
  lib,
  fetchpatch,
  fetchFromGitHub,
  buildPackages,
  pkgsCross,
}:

let
  buildHardkernelFirmware =
    {
      version ? null,
      src ? null,
      name ? "",
      filesToInstall,
      installDir ? "$out",
      defconfig,
      extraMeta ? { },
      ...
    }@args:
    stdenv.mkDerivation (
      {
        pname = "uboot-hardkernel-firmware-${name}";
        enableParallelBuilding = true;

        nativeBuildInputs = [
          buildPackages.git
          buildPackages.hostname
          pkgsCross.arm-embedded.stdenv.cc
        ];

        depsBuildBuild = [
          #buildPackages.gcc49
          buildPackages.gcc
        ]
        ++ lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) buildPackages.stdenv.cc
        ++ lib.optional (!stdenv.isAarch64) pkgsCross.aarch64-multiplatform.buildPackages.gcc;

        makeFlags = [
          "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
          "CROSS_COMPILE_32=${pkgsCross.arm-embedded.stdenv.cc.targetPrefix}"
          "${defconfig}"
          "bl301.bin"
        ]
        ++ lib.optional (
          !stdenv.isAarch64
        ) "CROSS_COMPILE=${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}";

        installPhase = ''
          mkdir -p ${installDir}
          cp ${lib.concatStringsSep " " filesToInstall} ${installDir}
        '';

        meta =
          with lib;
          {
            homepage = "https://www.hardkernel.com/";
            description = "Das U-Boot from Hardkernel with Odroid embedded devices firmware and support";
            license = licenses.unfreeRedistributableFirmware;
            maintainers = with maintainers; [ aarapov ];
          }
          // extraMeta;
      }
      // removeAttrs args [ "extraMeta" ]
    );
  preBuild = ''
    substituteInPlace Makefile --replace "/bin/pwd" "pwd"
  '';
in
# https://wiki.odroid.com/odroid-c4/software/building_u-boot
buildHardkernelFirmware {
  name = "firmware-odroid-c4";
  defconfig = "odroidc4_defconfig";
  version = "2015.01";
  src = fetchFromGitHub {
    owner = "hardkernel";
    repo = "u-boot";
    rev = "90ebb7015c1bfbbf120b2b94273977f558a5da46";
    sha256 = "0kv9hpsgpbikp370wknbyj6r6cyhp7hng3ng6xzzqaw13yy4qiz9";
  };

  preBuild = ''
    substituteInPlace ./arch/arm/cpu/armv8/g12a/firmware/scp_task/Makefile \
      --replace "CROSS_COMPILE" "CROSS_COMPILE_32"
    substituteInPlace ./Makefile \
      --replace "KBUILD_CFLAGS += -Werror" ""

    substituteInPlace ./common/bootm.c \
      --replace "unsigned long long dtbo_mem_addr = NULL;" "unsigned long long dtbo_mem_addr = 0;"

    substituteInPlace ./arch/arm/cpu/armv8/g12a/firmware/acs/Makefile \
      --replace "LDFLAGS			+=	--fatal-warnings -O1" "LDFLAGS			+=	-O1"

    touch ./include/linux/compiler-gcc14.h
  ''
  + preBuild;

  filesToInstall = [
    "build/board/hardkernel/odroidc4/firmware/acs.bin"
    "build/scp_task/bl301.bin"
    "fip/g12a/aml_ddr.fw"
    "fip/g12a/bl2.bin"
    "fip/g12a/bl30.bin"
    "fip/g12a/bl31.img"
    "fip/g12a/ddr3_1d.fw"
    "fip/g12a/ddr4_1d.fw"
    "fip/g12a/ddr4_2d.fw"
    "fip/g12a/diag_lpddr4.fw"
    "fip/g12a/lpddr3_1d.fw"
    "fip/g12a/lpddr4_1d.fw"
    "fip/g12a/lpddr4_2d.fw"
    "fip/g12a/piei.fw"
    "sd_fuse/sd_fusing.sh"
  ];

  extraMeta.platforms = [ "aarch64-linux" ];
}
