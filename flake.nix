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
      devShells = perSystemPkgs (pkgs: {
        egui-dev = pkgs.callPackage ./shell.nix { };
        default = inputs.self.devShells.${pkgs.system}.egui-dev;
      });
      formatter = perSystemPkgs (pkgs: pkgs.nixpkgs-fmt);
    };
}
