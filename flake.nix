{
  description = "A very basic flake";

  inputs = {
    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
  };

  outputs = inputs@{ ... }:
    let
      pkgImport = pkgs: system:
      import pkgs {
        system = system;
        config = { allowUnfree = true; };
      };
    in
  {
    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello;

  };
}
