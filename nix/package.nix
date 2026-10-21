{ lib, buildNpmPackage, electron, makeWrapper, makeDesktopItem, copyDesktopItems, src }:

buildNpmPackage {
  pname = "xodus-nexus";
  version = (builtins.fromJSON (builtins.readFile (src + "/package.json"))).version;
  inherit src;

  # Replace after the first build reports the correct npm dependency hash.
  npmDepsHash = "sha256-pzVbtFPUAG5tZohuD6cG2+bfK5dtfOP2rVkCav9XRtY=";
  npmFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper copyDesktopItems ];
  ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  # Compile the renderer and Electron main process, without creating an AppImage.
  buildPhase = ''
    runHook preBuild
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
