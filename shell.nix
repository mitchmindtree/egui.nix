{
  egui,
  lib,
  mkShell,
  stdenv,
}:
mkShell {
  name = "egui-dev";
  inputsFrom = [ egui ];
  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    inherit (egui) LD_LIBRARY_PATH XCURSOR_THEME;
  };
}
