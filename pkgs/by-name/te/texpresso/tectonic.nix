{
  tectonic-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  lib
}:

tectonic-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    pname = "texpresso-tonic";
    version = "0.15.0-unstable-2025-02-25";
    src = fetchFromGitHub {
      owner = "let-def";
      repo = "tectonic";
      rev = "c2ae25ff1facd9e9cce31b48944b867773f709ec";
      hash = "sha256-sew9r+M5CGACDaeSnAWcqE6RDED2o/YlY0m2BbEEZxc=";
      fetchSubmodules = true;
    };

    # patch "1155-fix-endless-reruns-when-generating-bbl" is now upstreamed
    patches = null;

    # patch "1202-fix-build-with-rust-1_80" is now upstreamed
    cargoPatches = null;

    useFetchCargoVendor = true;
    cargoHash = "sha256-dBthzRS+9wqKCwmo5cY/ynTdfIPK3QCsbZ2vAQ8q7aM=";
    # rebuild cargoDeps by hand because `.overrideAttrs cargoHash`
    # does not reconstruct cargoDeps (a known limitation):
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src;
      name = "${finalAttrs.pname}-${finalAttrs.version}";
      hash = finalAttrs.cargoHash;
      patches = finalAttrs.cargoPatches;
    };
    # binary has a different name, bundled tests won't work
    doCheck = false;
    postInstall = ''
      ${prevAttrs.postInstall or ""}

      # Remove the broken `nextonic` symlink
      # It points to `tectonic`, which doesn't exist because the exe is
      # renamed to texpresso-tonic
      rm $out/bin/nextonic
    '';
    meta = prevAttrs.meta // {
      mainProgram = "texpresso-tonic";
    };
  }
)
