{ atk
, cargo
, darwin
, egui-src
, fetchFromGitHub
, gcc
, gdk-pixbuf
, lib
, libxkbcommon
, libGL
, makeWrapper
, pango
, pkg-config
, rubyPackages_3_3
, rust-analyzer
, rustfmt
, rustPlatform
, stdenv
, vulkan-loader
, xorg
, wayland
, XCURSOR_THEME ? "Adwaita"
}:
let
  manifest = builtins.readFile "${egui-src}/Cargo.toml";
  toml = builtins.fromTOML manifest;
in
rustPlatform.buildRustPackage rec {
  pname = "egui";
  version = toml.workspace.package.version;
  src = egui-src;
  cargoLock.lockFile = "${egui-src}/Cargo.lock";
  doCheck = false;
  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  buildInputs = [
    cargo
    gcc
    rustfmt
    rust-analyzer
  ] ++ lib.optionals stdenv.isLinux [
    libxkbcommon
    # For those using OpenGL.
    libGL
    # For those using WGPU.
    vulkan-loader
    # For those on X11.
    xorg.libX11
    xorg.libxcb
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    # For those on Wayland.
    wayland
    # For the file_dialog example.
    atk
    gdk-pixbuf
    rubyPackages_3_3.gdk3
    pango
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.AppKit
  ];
  postFixup = lib.optionalString stdenv.isLinux ''
    for prog in $out/bin/*; do
      if [ -f "$prog" -a -x "$prog" ]; then
        wrapProgram "$prog" \
          --set LD_LIBRARY_PATH "${env.LD_LIBRARY_PATH}" \
          --set XCURSOR_THEME "${env.XCURSOR_THEME}"
      fi
    done
  '';
  env = lib.optionalAttrs stdenv.isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
    inherit XCURSOR_THEME;
  };
}
