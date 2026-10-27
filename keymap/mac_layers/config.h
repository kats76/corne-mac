#pragma once

#define VIAL_KEYBOARD_UID {0x89, 0x36, 0x2A, 0xC7, 0xFA, 0xD8, 0x89, 0x45}
#define VIAL_UNLOCK_COMBO_ROWS {0, 0}
#define VIAL_UNLOCK_COMBO_COLS {0, 1}

// La mitad esclava necesita conocer la capa activa para pintar sus LEDs
#define SPLIT_LAYER_STATE_ENABLE

// Color de cada capa. Valores posibles: HSV_AZURE, HSV_BLUE, HSV_CHARTREUSE, HSV_CORAL,
// HSV_CYAN, HSV_GOLD, HSV_GOLDENROD, HSV_GREEN, HSV_MAGENTA, HSV_ORANGE, HSV_PINK,
// HSV_PURPLE, HSV_RED, HSV_SPRINGGREEN, HSV_TEAL, HSV_TURQUOISE, HSV_WHITE, HSV_YELLOW.
// La capa base no se define aqui: usa el color elegido en la pestaña Lighting de Vial.
#define LAYER_1_COLOR HSV_BLUE
#define LAYER_2_COLOR HSV_GREEN
#define LAYER_3_COLOR HSV_RED
#define LAYER_4_COLOR HSV_YELLOW
#define LAYER_5_COLOR HSV_PURPLE

// Sin esto, la base arranca en rojo tras borrar la EEPROM y se confunde con la capa 3
#define RGB_MATRIX_DEFAULT_SAT 0
