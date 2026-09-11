#!/usr/bin/env bash
# Instala Flutter en la maquina de build de Vercel (no viene preinstalado).
# Se usa la misma version con la que se desarrolla el proyecto.
set -euo pipefail

FLUTTER_VERSION="3.47.0"
FLUTTER_DIR="$HOME/flutter"

# Flutter necesita unzip para descomprimir el SDK de Dart.
command -v unzip >/dev/null 2>&1 || dnf install -y unzip

if [ ! -x "$FLUTTER_DIR/bin/flutter" ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

"$FLUTTER_DIR/bin/flutter" config --no-analytics --enable-web
"$FLUTTER_DIR/bin/flutter" --version
"$FLUTTER_DIR/bin/flutter" pub get
