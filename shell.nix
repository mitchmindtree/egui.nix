{ egui
, mkShell
}:
mkShell {
  name = "egui-dev";
  inputsFrom = [ egui ];
  env = {
    inherit (egui) LD_LIBRARY_PATH XCURSOR_THEME;
  };
}
