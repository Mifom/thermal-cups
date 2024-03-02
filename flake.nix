{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem(system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages = rec {
      default = thermal-cups;
      thermal-cups = pkgs.stdenv.mkDerivation {
      name="thermal-cups";
      nativeBuildInputs = with pkgs; [zig cups];
      src = self;
      buildPhase = ''
        mkdir .cache
        export XDG_CACHE_HOME=.cache
        zig build install -Dgenerate_ppd=true -Dnew_raster=true
        mkdir -p $out/lib/cups/filter/
        cp zig-out/bin/* $out/lib/cups/filter
        mkdir -p $out/share/cups/model/zjiang
        mkdir -p $out/share/cups/model/xprinter
        cp zig-out/ppd/zj* $out/share/cups/model/zjiang/
        cp zig-out/ppd/xp* $out/share/cups/model/xprinter/
      '';
      };
    };
  });
}
