#!/usr/bin/env bash
# Compila el firmware dentro de Docker para no instalar el toolchain de QMK en el sistema
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QMK_DIR="${QMK_DIR:-$ROOT/.cache/vial-qmk}"
KEYMAP="mac_layers"
# Solo rev4_1/standard esta probado; otra revision se elige con KEYBOARD=crkbd/rev4_0/standard
KEYBOARD="${KEYBOARD:-crkbd/rev4_1/standard}"
IMAGE="ghcr.io/qmk/qmk_cli:latest"

# Sin esta comprobacion, el error de Docker aparece despues de descargar vial-qmk y no explica que hacer
if ! docker info >/dev/null 2>&1; then
    echo "Docker no responde. Abre Docker Desktop (o inicia el servicio de Docker) y vuelve a ejecutar el script." >&2
    exit 1
fi

echo "[1/4] Preparando vial-qmk"
"$ROOT/scripts/fetch-vial-qmk.sh" "$QMK_DIR"

echo "[2/4] Copiando el keymap $KEYMAP"
rsync -a --delete "$ROOT/keymap/$KEYMAP/" "$QMK_DIR/keyboards/crkbd/keymaps/$KEYMAP/"

echo "[3/4] Preparando la imagen $IMAGE"
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
    echo "      Primera vez: se descarga la imagen de QMK (varios GB)"
    docker pull "$IMAGE"
fi

echo "[4/4] Compilando $KEYBOARD:$KEYMAP"
# Compilar no necesita red, asi que se corta para que nada del contenedor salga a internet
docker run --rm --network none -e HOME=/tmp -u "$(id -u):$(id -g)" \
    -v "$QMK_DIR:/qmk_firmware" -w /qmk_firmware "$IMAGE" \
    make "$KEYBOARD:$KEYMAP"

TARGET="${KEYBOARD//\//_}"
mkdir -p "$ROOT/dist"
cp "$QMK_DIR/${TARGET}_$KEYMAP.uf2" "$ROOT/dist/${TARGET}_$KEYMAP.uf2"
echo "Firmware listo: dist/${TARGET}_$KEYMAP.uf2"
