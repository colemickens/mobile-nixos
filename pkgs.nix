let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  flake = (import
    (fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
        sha256 = lock.nodes.flake-compat.locked.narHash;
    }) {
      src = ./.;
    }
  );
in
  builtins.trace
    "(Using pinned Nixpkgs at ${lock.nodes.nixpkgs.locked.rev})"
    (import flake.defaultNix.inputs.nixpkgs {})
