{
  description = "A bible used on cli and on fortune.";


  outputs = { self, nixpkgs }:
    let

      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";
      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {


      packages = forAllSystems (system:
          with nixpkgsFor.${system};
      {

      fortune = pkgs.stdenv.mkDerivation rec {
          pname = "fortune-mod";
          version = "3.20.0";

          # We use fetchurl instead of fetchFromGitHub because the release pack has some
          # special files.
          src = pkgs.fetchurl {
            url = "https://github.com/shlomif/fortune-mod/releases/download/${pname}-${version}/${pname}-${version}.tar.xz";
            sha256 = "sha256-MQG+lfuJxISNSD5ykw2o0D9pJXN6I9eIA9a1XEL+IJQ=";
          };

          nativeBuildInputs = [ pkgs.cmake pkgs.perl pkgs.rinutils ];

          buildInputs = [ pkgs.recode ];

          cmakeFlags = [
            "-DLOCALDIR=${placeholder "out"}/share/fortunes"
          ];

          patches = [ (builtins.toFile "not-a-game.patch" ''
            diff --git a/CMakeLists.txt b/CMakeLists.txt
            index 865e855..5a59370 100644
            --- a/CMakeLists.txt
            +++ b/CMakeLists.txt
            @@ -154,7 +154,7 @@ ENDMACRO()
             my_exe(
                 "fortune"
                 "fortune/fortune.c"
            -    "games"
            +    "bin"
             )

             my_exe(
            --
          '') ];

          meta = with pkgs.lib; {
            mainProgram = "fortune";
            description = "A program that displays a pseudorandom message from a database of quotations";
            license = licenses.bsdOriginal;
            platforms = platforms.unix;
            maintainers = with maintainers; [ vonfry ];
          };
        };
       default = fortune;
       defaultPackage = forAllSystems (system: self.packages.${system}.samplePackage);

    });
  };
}
