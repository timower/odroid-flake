# Original source:
# https://github.com/samueldr/nixpkgs/blob/wip/odroidc4/pkgs/misc/meson64-tools/default.nix
{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "meson64-tools";
  version = "unstable-2020-08-03";

  src = fetchFromGitHub {
    owner = "angerman";
    repo = pname;
    rev = "b09cefd1e001dbba14036857bf6e167bf1833f26";
    hash = "sha256-/koIsslDNpaFHf1TV/0Xt0TiyhjL6tCz2oHQraYNhPA=";
  };

  buildInputs = with buildPackages; [
    openssl
    bison
    flex
    bc
    python3
  ];

  preBuild = ''
    patchShebangs .
    substituteInPlace mbedtls/programs/fuzz/Makefile --replace "python2" "python"
    substituteInPlace mbedtls/tests/Makefile --replace "python2" "python"
  '';

  makeFlags = [ "PREFIX=$(out)/bin" ];
  enableParallelBuilding = true;

  meta = with lib; {
    homepage = "https://github.com/angerman/meson64-tools";
    description = "Tools for Amlogic Meson ARM64 platforms";
    license = licenses.mit;
    maintainers = with maintainers; [ aarapov ];
  };
}
