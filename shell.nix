{ atk
, cargo
, darwin
, gcc
, gdk-pixbuf
, lib
, libxkbcommon
, libGL
, mkShell
, pango
, pkg-config
, rubyPackages_3_3
, rust-analyzer
, rustfmt
, stdenv
, vulkan-loader
, xorg
, wayland
}:
mkShell rec {
  nativeBuildInputs = [
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
  env = lib.optionalAttrs stdenv.isLinux {
    LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
  };
}
