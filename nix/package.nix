{ lib, buildNpmPackage, electron, coreutils, bash, nodejs, makeWrapper, makeDesktopItem, copyDesktopItems, src }:

buildNpmPackage {
  pname = "xodus-nexus";
  version = (builtins.fromJSON (builtins.readFile (src + "/package.json"))).version;
  inherit src;

  npmDepsHash = "sha256-pzVbtFPUAG5tZohuD6cG2+bfK5dtfOP2rVkCav9XRtY=";
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper copyDesktopItems coreutils bash ];

  # Upstream subprocess tests assume /bin/sh, /bin/echo and a conventional PATH.
  # Nix builders have no /bin; patch fixture paths in the unpacked copy only.
  postPatch = ''
    substituteInPlace src/main/game-shortcuts.test.ts \
      --replace-fail "'/bin/echo'" "'${coreutils}/bin/echo'"
    # Synthetic test fixtures often use #!/bin/sh; patch their generated scripts
    # if the next build still fails rather than bypassing tests.
  '';
  # Fixture scripts use /bin/sh and /usr/bin/env, unavailable in a Nix sandbox.
  # patchShebangs rewrites shebangs in the temporary build tree.
  preBuild = ''
    patchShebangs src/main
  '';
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # Compile the renderer and Electron main process, without creating an AppImage.
  buildPhase = ''
    runHook preBuild
    export PATH="${coreutils}/bin:${bash}/bin:${nodejs}/bin:$PATH"
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/xodus-nexus" "$out/bin" "$out/share/icons/hicolor/256x256/apps"
    cp -r dist dist-electron assets package.json "$out/share/xodus-nexus/"
    cp assets/icon.png "$out/share/icons/hicolor/256x256/apps/xodus-nexus.png"
    makeWrapper "${electron}/bin/electron" "$out/bin/xodus-nexus" \
      --add-flags "$out/share/xodus-nexus"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "xodus-nexus";
      desktopName = "Xodus Nexus";
      exec = "xodus-nexus";
      icon = "xodus-nexus";
      categories = [ "Game" ];
    })
  ];

  meta = {
    description = "Xbox-inspired launcher for Xodus on Linux";
    homepage = "https://github.com/domsvoboda/xodus-nexus";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "xodus-nexus";
  };
}
