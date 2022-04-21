    .include "include/macros.s"
    .include "include/constants.s"
    .include "include/errors.s"

    .org $C000 ; Monitor OS area
    .include "include/monitor/banner.s"
    .include "include/monitor/monitor.s"
    
    .org $E000 ; Kernel area

    .include "include/utils/hex_utils.s"
    .include "include/utils/str_utils.s"
    .include "include/utils/error_utils.s"
    .include "include/io/io_generic.s"
    .include "include/io/spi.s"

    .include "include/io/sd/init.s"
    .include "include/io/sd/ops.s"

    .ifdef GRAPHIC_OUTPUT
    .include "include/io/graphic/graphic.s"
    .include "include/io/graphic/io_graphic.s"
    .else
    .include "include/io/lcd/lcd_8bit.s"
    .include "include/io/lcd/io_lcd.s"
    .endif

    .include "include/vectors.s"

    .include "include/keymap.s"

    .org $FFFA
    .word nmi
    .word reset
    .word irq