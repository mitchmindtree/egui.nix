{
  atk,
  cargo,
  darwin,
  egui-src,
  gcc,
  gdk-pixbuf,
  lib,
  libxkbcommon,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  makeWrapper,
  pango,
  pkg-config,
  rubyPackages_3_3,
  rust-analyzer,
  rustfmt,
  rustPlatform,
  stdenv,
  vulkan-loader,
  wayland,
  XCURSOR_THEME ? "Adwaita",
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
  ]
  ++ lib.optionals stdenv.isLinux [
    libxkbcommon
    # For those using OpenGL.
    libGL
    # For those using WGPU.
    vulkan-loader
    # For those on X11.
    libx11
    libxcb
    libxcursor
    libxi
    libxrandr
    # For those on Wayland.
    wayland
    # For the file_dialog example.
    atk
    gdk-pixbuf
    rubyPackages_3_3.gdk3
    pango
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
