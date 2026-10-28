#!/usr/bin/env bash
# Descarga vial-qmk en un commit fijo para que cualquiera compile exactamente el mismo firmware
# Uso: fetch-vial-qmk.sh <carpeta destino>
set -euo pipefail

VIAL_QMK_REF="dd43959ae5c08d8a28d38a1acf7b04e86b14a344"
DEST="$1"

if [ -d "$DEST/.git" ] && [ "$(git -C "$DEST" rev-parse HEAD)" = "$VIAL_QMK_REF" ]; then
    echo "      vial-qmk ya esta descargado"
    exit 0
fi

# La descarga tarda minutos; sin progreso visible parece que el script se colgo
echo "      Primera vez: se descarga vial-qmk y sus submodulos (unos cientos de MB, puede tardar unos minutos)"
rm -rf "$DEST"
git init -q "$DEST"
git -C "$DEST" remote add origin https://github.com/vial-kb/vial-qmk.git
git -C "$DEST" fetch --progress --depth 1 origin "$VIAL_QMK_REF"
git -C "$DEST" checkout -q FETCH_HEAD
git -C "$DEST" submodule update --progress --init --recursive --depth 1
