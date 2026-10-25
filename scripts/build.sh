#!/usr/bin/env bash
# Compila el firmware dentro de Docker para no instalar el toolchain de QMK en el sistema
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QMK_DIR="${QMK_DIR:-$ROOT/.cache/vial-qmk}"
KEYMAP="mac_layers"
KEYBOARD="crkbd/rev4_1/standard"
IMAGE="ghcr.io/qmk/qmk_cli:latest"

"$ROOT/scripts/fetch-vial-qmk.sh" "$QMK_DIR"
rsync -a --delete "$ROOT/keymap/$KEYMAP/" "$QMK_DIR/keyboards/crkbd/keymaps/$KEYMAP/"

# Compilar no necesita red, asi que se corta para que nada del contenedor salga a internet
docker run --rm --network none -e HOME=/tmp -u "$(id -u):$(id -g)" \
    -v "$QMK_DIR:/qmk_firmware" -w /qmk_firmware "$IMAGE" \
    make "$KEYBOARD:$KEYMAP"

mkdir -p "$ROOT/dist"
cp "$QMK_DIR/crkbd_rev4_1_standard_$KEYMAP.uf2" "$ROOT/dist/corne-mac-layers.uf2"
echo "Firmware listo: dist/corne-mac-layers.uf2"
