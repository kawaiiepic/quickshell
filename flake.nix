{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        quickshell =  inputs.quickshell.packages.${system}.default.withModules [
          pkgs.kdePackages.qt5compat
        ];

        devShells.default = pkgs.mkShell {
          buildInputs = [
            quickshell
            pkgs.kdePackages.qtdeclarative
          ];

          shellHook = ''
            # Required for qmlls to find the correct type declarations
            export QMLLS_BUILD_DIRS=${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${quickshell}/lib/qt-6/qml/
            export QML_IMPORT_PATH=$PWD/src
          '';
        };
      in
      {
        inherit devShells;
      }
    );
}
