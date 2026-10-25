#!/usr/bin/env python3
# Convierte un .vil de Vial al YAML de keymap-drawer para generar las imagenes de las capas.
# Uso: vil_to_drawer.py <archivo.vil> <salida.yaml> <nombre capa 0> [<nombre capa 1> ...]
import json
import sys

# Orden fisico de LAYOUT_split_3x6_3_ex2: (fila de la matriz, columna)
# La mitad derecha esta guardada al reves en la matriz (columna 0 = exterior)
LAYOUT_ORDER = (
    [(0, c) for c in range(7)] + [(4, c) for c in range(6, -1, -1)]
    + [(1, c) for c in range(7)] + [(5, c) for c in range(6, -1, -1)]
    + [(2, c) for c in range(6)] + [(6, c) for c in range(5, -1, -1)]
    + [(3, c) for c in range(3, 6)] + [(7, c) for c in range(5, 2, -1)]
)

NAMES = {
    "ESCAPE": "Esc", "TAB": "Tab", "SPACE": "Space", "ENTER": "Enter", "BSPACE": "Bksp",
    "DELETE": "Del", "LSHIFT": "Shift", "RSHIFT": "Shift", "LCTRL": "Ctrl", "RCTRL": "Ctrl",
    "LALT": "Alt", "RALT": "Alt", "LGUI": "Gui", "RGUI": "Gui", "MINUS": "-", "EQUAL": "=",
    "LBRACKET": "[", "RBRACKET": "]", "BSLASH": "\\", "SCOLON": ";", "QUOTE": "'", "GRAVE": "`",
    "COMMA": ",", "DOT": ".", "SLASH": "/", "LEFT": "Left", "RIGHT": "Right", "UP": "Up",
    "DOWN": "Down", "HOME": "Home", "END": "End", "MPLY": "Play", "MNXT": "Next", "MPRV": "Prev",
    "VOLU": "Vol+", "VOLD": "Vol-", "MUTE": "Mute",
}
SHIFTED = {
    "1": "!", "2": "@", "3": "#", "4": "$", "5": "%", "6": "^", "7": "&", "8": "*", "9": "(",
    "0": ")", "-": "_", "=": "+", "[": "{", "]": "}", "\\": "|", "`": "~",
}
# Atajos de un solo codigo que conviene nombrar por lo que hacen, no por sus modificadores
SHORTCUTS = {
    0x0B21: "Shot area", 0x0B20: "Shot screen", 0x0A22: "Shot menu", 0x082C: "Spotlight",
    0x0850: "Line start", 0x084F: "Line end", 0x0450: "Word left", 0x044F: "Word right",
    0x0150: "Desk left", 0x014F: "Desk right",
}
# Codigos basicos de Vial v6 que aparecen dentro de atajos numericos
BASIC = {0x29: "Esc", 0x2C: "Space", 0x50: "Left", 0x4F: "Right", 0x20: "3", 0x21: "4", 0x22: "5"}


def mods_label(mask, os_name):
    gui = "Cmd" if os_name == "mac" else "Win"
    alt = "Opt" if os_name == "mac" else "Alt"
    parts = [n for bit, n in ((1, "Ctrl"), (2, "Shift"), (4, alt), (8, gui)) if mask & bit]
    return "+".join(parts)


def basic_label(name):
    name = name.removeprefix("KC_")
    return NAMES.get(name, name)


def key_label(code, os_name):
    if code == -1:
        return None
    if isinstance(code, int):
        if code in SHORTCUTS:
            return SHORTCUTS[code]
        if 0x2000 <= code <= 0x3FFF:
            return {"t": BASIC.get(code & 0xFF, hex(code & 0xFF)), "h": mods_label((code >> 8) & 0x1F, os_name)}
        if 0x0100 <= code <= 0x1FFF:
            return mods_label((code >> 8) & 0x1F, os_name) + "+" + BASIC.get(code & 0xFF, hex(code & 0xFF))
        return hex(code)
    if code == "KC_TRNS":
        return {"type": "trans"}
    if code == "KC_NO":
        return ""
    if code.startswith("LSFT(") and code.endswith(")"):
        inner = basic_label(code[5:-1])
        return SHIFTED.get(inner, "Shift+" + inner)
    for prefix, label in (("MO(", "Hold L"), ("TO(", "To L"), ("TT(", "TT L"), ("TD(", "TD ")):
        if code.startswith(prefix):
            return label + code[len(prefix):-1]
    if code in ("KC_LGUI", "KC_RGUI"):
        return "Cmd" if os_name == "mac" else "Win"
    if code == "KC_LALT" and os_name == "mac":
        return "Opt"
    if code.startswith("RGB_"):
        return "RGB " + code[4:].lower()
    return basic_label(code)


def main():
    src, dst, names = sys.argv[1], sys.argv[2], sys.argv[3:]
    os_name = "mac" if "mac" in dst else "windows"
    layout = json.load(open(src))["layout"]
    layers = {}
    for index, name in enumerate(names):
        if name == "-":
            continue
        layers[name] = [key_label(layout[index][r][c], os_name) for r, c in LAYOUT_ORDER]
    doc = {
        "layout": {"qmk_keyboard": "crkbd/rev4_1/standard", "layout_name": "LAYOUT_split_3x6_3_ex2"},
        "layers": layers,
    }
    # JSON es YAML valido, asi no hace falta instalar PyYAML
    json.dump(doc, open(dst, "w"), indent=1, ensure_ascii=False)


if __name__ == "__main__":
    main()
