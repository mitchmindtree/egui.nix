{
  description = "A flake for egui";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    let
      systems = import inputs.systems;
      lib = inputs.nixpkgs.lib;
      perSystem = f: lib.genAttrs systems f;
      systemPkgs = system: import inputs.nixpkgs { inherit system; };
      perSystemPkgs = f: perSystem (system: f (systemPkgs system));
    in
    {
      packages = perSystemPkgs (pkgs: {
        egui = pkgs.callPackage ./default.nix { };
        default = inputs.self.packages.${pkgs.system}.egui;
      });

      apps = perSystemPkgs (pkgs:
        let
          egui = inputs.self.packages.${pkgs.system}.egui;
        in
        {
          hello-world = {
            type = "app";
            program = "${egui}/bin/hello_world";
          };
          demo = {
            type = "app";
            program = "${egui}/bin/egui_demo_app";
          };
        });

      devShells = perSystemPkgs (pkgs: {
        egui-dev = pkgs.callPackage ./shell.nix {
          inherit (inputs.self.packages.${pkgs.system}) egui;
        };
        default = inputs.self.devShells.${pkgs.system}.egui-dev;
      });

      lib = perSystemPkgs (pkgs: {
        buildEguiPackage =
          { nativeBuildInputs
          , buildInputs
          ,
          }: pkgs.rustPlatform.buildRustPackage { };
      });

      formatter = perSystemPkgs (pkgs: pkgs.nixpkgs-fmt);
    };
}
