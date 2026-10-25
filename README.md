# Corne v4 for macOS

[Leer en español](README.es.md)

A Vial layout designed for macOS plus a firmware with a **per-layer RGB indicator** for the foostan **Corne v4.1 standard** (46 keys, RP2040).

- `layouts/corne-mac.vil`: the Mac layout. Load it in Vial with **File > Load saved layout**.
- `layouts/corne-windows.vil`: the original Windows layout, kept as a backup.
- `keymap/mac_layers/`: foostan's official Vial firmware plus the layer color indicator.
- Prebuilt firmware: download `corne-mac-layers.uf2` from [Releases](../../releases).

## The Mac layout

Modifiers and layers live on the thumbs: one hand holds the layer, the other one types. Cmd sits on the thumb that is Ctrl on Windows, so Cmd+C/V uses the same finger your muscle memory expects.

![Mac layers](docs/img/layers-mac.svg)

- **Esc**: Esc on tap, Ctrl on hold (terminal, tmux, vim).
- **Shot area**: screenshot of an area to the clipboard (Ctrl+Shift+Cmd+4) with a single key.
- **Spotlight**: Cmd+Space on its own key, since Cmd and Space share the left thumb.
- **Line start / Line end**: Cmd+Left and Cmd+Right. On a Mac, Home and End scroll the document instead.
- **Num + Nav layer**: plain modifiers on the left home row, so Shift+Opt+Right selects word by word without twisting your hand.

### Original Windows layout

<details>
<summary>Show the Windows layers</summary>

![Windows layers](docs/img/layers-windows.svg)

</details>

## Layer colors

The whole keyboard changes color with the active layer, so you always know where you are:

| Layer | Color |
| --- | --- |
| 0 Base | Dim white |
| 1 Num + Nav | Blue |
| 2 Symbols | Green |
| 3 Fn + Media | Red |

The firmware keeps foostan's Vial UID, so any `.vil` keeps loading. `SPLIT_LAYER_STATE_ENABLE` sends the active layer to the secondary half so both halves light up the same.

## Build

You only need Docker. The QMK toolchain is never installed on your system: everything runs in the official `ghcr.io/qmk/qmk_cli` image with networking disabled. vial-qmk is pinned to a fixed commit, so every build is reproducible.

```bash
./scripts/build.sh
```

The firmware ends up in `dist/corne-mac-layers.uf2`. CI builds it on every push and attaches it to each `v*` tag release.

On Windows, run the scripts from WSL or Git Bash with Docker Desktop.

## Flash

The Corne v4.1 has no reset button. Use bootmagic instead, which also wipes the keyboard memory.

1. Unplug the USB cable, then the TRRS cable between the halves.
2. Left half: hold **Q** and plug in the USB cable. A drive called `RPI-RP2` appears; copy the `.uf2` onto it.
3. Unplug the USB cable. Right half: hold **P** and plug in the USB cable. Copy the same `.uf2`.
4. With USB unplugged, reconnect the TRRS cable. Plug USB into the left half.
5. In Vial: **File > Load saved layout** and pick `layouts/corne-mac.vil`.

**Never plug or unplug the TRRS cable while USB is connected:** it can damage the microcontroller.

## Make your own layout

1. Fork this repo and load `layouts/corne-mac.vil` in Vial.
2. Change whatever you want; Vial writes it to the keyboard in real time.
3. Export with **File > Save current layout** over `layouts/corne-mac.vil`.
4. Run `./scripts/draw.sh` to regenerate the layer images.
5. Open a pull request if you want to share it.

To change the layer colors, edit `rgb_matrix_indicators_advanced_user` in `keymap/mac_layers/keymap.c` and rebuild.

## Credits and license

Based on foostan's Vial firmware from [foostan/kbd_firmware](https://github.com/foostan/kbd_firmware) and on [vial-qmk](https://github.com/vial-kb/vial-qmk). Layer images are generated with [keymap-drawer](https://github.com/caksoylar/keymap-drawer).

Licensed under [GPL-2.0-or-later](LICENSE), like the projects it derives from.
