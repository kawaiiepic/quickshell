{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qml-niri = {
      url = "github:imiric/qml-niri/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };

        libs = with pkgs; [
          pkg-config
          portaudio
          piper
        ];

        quickshelled = inputs.quickshell.packages.${system}.default.withModules [
          pkgs.kdePackages.qt5compat
          pkgs.kdePackages.qtimageformats
          pkgs.kdePackages.qtmultimedia
          pkgs.kdePackages.qtwebsockets
          inputs.qml-niri.packages.${system}.default
        ];

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            coreutils
            gawk
            ripgrep
            procps
            util-linux

            quickshelled
            pkgs.kdePackages.qtdeclarative

            uv
            pkg-config
            portaudio
          ];

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libs}
            export QML_IMPORT_PATH=${quickshelled}/lib/qt-6/qml/:${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml/:${
              inputs.qml-niri.packages.${system}.default
            }/lib/qt-6/qml/:${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml
          '';
        };
      in
      {
        inherit devShells;
      }
    );
}
