{
  description = "Flake para gerar projeto experimental e fazer o latex";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    starvz.url = "github:schnorr/starvz";
  };
  outputs = { self, starvz, nixpkgs }: 
      let 
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
        rEnv = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [
                languageserver
                lintr
                here
                DoE_base
                FrF2
                tidyverse
                janitor
                starvz.packages.${system}.starvz
            ];
        };
    in 
  {
        devShells.${system}.default = pkgs.mkShell { buildInputs =  [ rEnv ]; };
  };
}
