# Adapted from github:samueldr/nixpkgs?ref=wip/odroidc4
# Changes:
#  * Upstream uboot, keeping meson64-tools and firwmare
#  * Enable btrfs support.
{
  buildUBoot,
  meson64-tools,
  firmwareOdroidC4,
}:
buildUBoot {
  defconfig = "odroid-c4_defconfig";
  extraConfig = ''
    CONFIG_FS_BTRFS=y
  '';

  postBuild = ''
    ${meson64-tools}/bin/pkg --type bl30 --output bl30_new.bin \
      ${firmwareOdroidC4}/bl30.bin ${firmwareOdroidC4}/bl301.bin
    ${meson64-tools}/bin/pkg --type bl2 --output bl2_new.bin \
      ${firmwareOdroidC4}/bl2.bin ${firmwareOdroidC4}/acs.bin

    ${meson64-tools}/bin/bl30sig --input bl30_new.bin \
      --output bl30_new.bin.g12a.enc --level v3
    ${meson64-tools}/bin/bl3sig --input  bl30_new.bin.g12a.enc \
      --output bl30_new.bin.enc --level v3 --type bl30
    ${meson64-tools}/bin/bl3sig --input ${firmwareOdroidC4}/bl31.img \
      --output bl31.img.enc --level v3 --type bl31
    ${meson64-tools}/bin/bl3sig --input u-boot.bin --compress lz4 \
      --output bl33.bin.enc --level v3 --type bl33 --compress lz4
    ${meson64-tools}/bin/bl2sig --input bl2_new.bin \
      --output bl2.n.bin.sig

    ${meson64-tools}/bin/bootmk --output u-boot.bin \
      --bl2 bl2.n.bin.sig --bl30 bl30_new.bin.enc --bl31 bl31.img.enc --bl33 bl33.bin.enc \
      --ddrfw1 ${firmwareOdroidC4}/ddr4_1d.fw \
      --ddrfw2 ${firmwareOdroidC4}/ddr4_2d.fw \
      --ddrfw3 ${firmwareOdroidC4}/ddr3_1d.fw \
      --ddrfw4 ${firmwareOdroidC4}/piei.fw \
      --ddrfw5 ${firmwareOdroidC4}/lpddr4_1d.fw \
      --ddrfw6 ${firmwareOdroidC4}/lpddr4_2d.fw \
      --ddrfw7 ${firmwareOdroidC4}/diag_lpddr4.fw \
      --ddrfw8 ${firmwareOdroidC4}/aml_ddr.fw \
      --ddrfw9 ${firmwareOdroidC4}/lpddr3_1d.fw \
      --level v3
  '';

  filesToInstall = [
    "u-boot.bin"
    "${firmwareOdroidC4}/sd_fusing.sh"
  ];

  extraMeta.platforms = [ "aarch64-linux" ];
}
