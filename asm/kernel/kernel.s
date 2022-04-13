    .include "include/macros.s"

    .org $C000 ; Monitor OS area
    .include "include/constants.s"
    .include "include/monitor.s"
    
    .org $E000 ; Kernel area

    .include "include/hex_utils.s"
    .include "include/str_utils.s"
    .include "include/io_generic.s"

    .ifdef GRAPHIC_OUTPUT
    .include "include/graphic.s"
    .include "include/io_graphic.s"
    .else
    .include "include/lcd_8bit.s"
    .include "include/io_lcd.s"
    .endif

    .include "include/vectors.s"

    .include "include/keymap.s"

    .org $FFFA
    .word nmi
    .word reset
    .word irq