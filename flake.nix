{
  description = "Digital rain for modern terminals";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          rmatrix = pkgs.rustPlatform.buildRustPackage {
            pname = "rmatrix";
            version = "0.1.0";

            src = self;

            cargoLock = {
              lockFile = ./Cargo.lock;
            };

            meta = {
              description = "Digital rain for modern terminals";
              homepage = "https://github.com/Tripstack-Corp/rmatrix";
              license = pkgs.lib.licenses.mit;
              mainProgram = "rmatrix";
              platforms = pkgs.lib.platforms.unix;
            };
          };
          default = self.packages.${system}.rmatrix;
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.rmatrix}/bin/rmatrix";
        };
      });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              cargo
              clippy
              rustc
              rustfmt
            ];
          };
        });
    };
}
