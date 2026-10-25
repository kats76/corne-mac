#!/usr/bin/env bash
# Regenera las imagenes de las capas a partir de los .vil, con keymap-drawer dentro de Docker
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

python3 -I "$ROOT/scripts/vil_to_drawer.py" "$ROOT/layouts/corne-mac.vil" "$ROOT/docs/keymap-mac.yaml" \
    "Base" "Num + Nav" "Symbols" "Fn + Media"
python3 -I "$ROOT/scripts/vil_to_drawer.py" "$ROOT/layouts/corne-windows.vil" "$ROOT/docs/keymap-windows.yaml" \
    "Base" "Num + Nav" "Symbols" "RGB" "-" "F keys"

# Solo se monta docs/: el contenedor no ve nada mas del sistema
docker run --rm -u "$(id -u):$(id -g)" -e HOME=/tmp -v "$ROOT/docs:/work" -w /work python:3.12-slim sh -c '
    pip install --quiet --user --no-warn-script-location keymap-drawer==0.23.0
    /tmp/.local/bin/keymap draw keymap-mac.yaml > img/layers-mac.svg
    /tmp/.local/bin/keymap draw keymap-windows.yaml > img/layers-windows.svg
'
echo "Imagenes en docs/img/"
