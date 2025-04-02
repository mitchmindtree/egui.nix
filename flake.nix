{
  description = "A flake for egui";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    egui-src = {
      url = "github:emilk/egui/0.28.1";
      flake = false;
    };
  };

  outputs = inputs:
    let
      systems = import inputs.systems;
      overlays = [ inputs.self.overlays.default ];
      lib = inputs.nixpkgs.lib;
      perSystem = f: lib.genAttrs systems f;
      systemPkgs = system: import inputs.nixpkgs { inherit overlays system; };
      perSystemPkgs = f: perSystem (system: f (systemPkgs system));
    in
    {
      overlays = {
        egui = final: prev: {
          egui = prev.callPackage ./default.nix {
            inherit (inputs) egui-src;
          };
        };
        default = inputs.self.overlays.egui;
      };

      packages = perSystemPkgs (pkgs: {
        egui = pkgs.egui;
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
