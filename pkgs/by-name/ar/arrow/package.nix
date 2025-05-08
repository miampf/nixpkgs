{
  stdenv,
  lib,
  fetchFromGitHub,
  godot_4_3,
  alsa-lib,
  libGL,
  libpulseaudio,
  libX11,
  libXcursor,
  libXext,
  libXi,
  libXrandr,
  udev,
  vulkan-loader,
  autoPatchelfHook,
  makeDesktopItem,
  copyDesktopItems,
  inkscape,
  nix-update-script,
  ...
}:

let
  godot = godot_4_3;
  godot_version_folder = lib.replaceStrings [ "-" ] [ "." ] godot.version;
in
stdenv.mkDerivation rec {
  pname = "arrow";
  version = "3.0.0";
  description = "Game Narrative Design Tool";

  src = fetchFromGitHub {
    owner = "mhgolkar";
    repo = "Arrow";
    tag = "v${version}";
    hash = "sha256-oodW6XvesBWic0yK1Se/tycjqblE4qUSuAk+3MY3x8I=";
  };

  desktopItems = [
    (makeDesktopItem {
      type = "Application";
      name = "Arrow";
      exec = "Arrow";
      icon = "Arrow";
      terminal = false;
      comment = "Game Narrative Design Tool";
      desktopName = "Arrow";
      categories = [ "Application" ];
    })
  ];

  buildInputs = [
    godot_4_3
    inkscape
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    godot
    copyDesktopItems
  ];

  runtimeDependencies = map lib.getLib [
    alsa-lib
    libGL
    libpulseaudio
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
    udev
    vulkan-loader
  ];

  passthru.updateScript = nix-update-script {};

  buildPhase = ''
    runHook preBuild

    export HOME=$TMPDIR

    mkdir -p $HOME/.local/share/godot/export_templates
    ln -s "${godot.export-templates-bin}" $HOME/.local/share/godot/export_templates/${godot_version_folder}

    mkdir -p build
    godot4 --headless --export-release Linux ./build/Arrow

    inkscape -w 256 -h 256 icon.svg -o ./build/icon.png

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 755 -t $out/libexec ./build/Arrow
    install -D -m 644 -t $out/libexec ./build/Arrow.pck

    install -d -m 755 $out/bin
    ln -s $out/libexec/Arrow $out/bin/Arrow

    install -d -m 755 $out/share/icons/hicolor/256x256/apps
    install -vD ./build/icon.png $out/share/icons/hicolor/256x256/apps/Arrow.png

    runHook postInstall
  '';
}
