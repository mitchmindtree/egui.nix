{ egui
, lib
, mkShell
, stdenv
}:
mkShell {
  name = "egui-dev";
  inputsFrom = [ egui ];
  env = lib.optionalAttrs stdenv.isLinux {
    inherit (egui) LD_LIBRARY_PATH XCURSOR_THEME;
  };
}
