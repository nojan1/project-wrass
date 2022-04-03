    .org $C000 ; Monitor OS area

    .include "include/constants.s"
    .include "include/monitor.s"
    
    .org $E000 ; Kernel area

    .include "include/str_utils.s"
    .include "include/io.s"
    .include "include/lcd_8bit.s"
    .include "include/vectors.s"

    .include "include/keymap.s"

    .org $FFFA
    .word nmi
    .word reset
    .word irq