# NixOS source-build experiment

This is an **initial, unverified** source-build package for the Nexus launcher.
The backend and game runtime are separate components and are not packaged here.

## Test

```sh
nix build .#default --show-trace -L
nix run .#default
```

The first build is expected to fail because `npmDepsHash` is deliberately set to
`lib.fakeHash`. Copy the **got:** SRI hash from the fixed-output dependency
hash mismatch into `nix/package.nix`, then rebuild.

Note: upstream pins Electron 44.8.0 in npm, while this flake currently uses
the Electron version available from nixpkgs. Check that the runtime Electron
version is compatible before submitting upstream. The Nix build may also
expose missing native dependencies or packaging assumptions.

## Installing in a host flake

Add:

```nexus.url = "github:OmarDardery/xodus-nexus/feat/nix-flake";
```

Then in a NixOS module with access to `inputs`:

```nixpkgs.overlays = [ ];
environment.systemPackages = [
  inputs.nexus.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

For Home Manager, use `home.packages` instead.

`nix flake update nexus` advances the source pin when this repository is
used as a flake input. Npm lockfile changes may require updating the Nix
dependency hash in the package source.
