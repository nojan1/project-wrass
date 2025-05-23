    .include "include/macros.s"
    .include "include/variables.s"
    .include "include/constants.s"
    .include "include/errors.s"

    .org $C000 ; Monitor OS area
    .include "include/utils/hex_utils.s"

    .ifdef BASIC
    .include "include/basic/init.s"
    .else
    .include "include/monitor/banner.s"
    .include "include/monitor/monitor.s"

    .org $E000 ; Kernel area
    .include "exports.s"

    .include "include/utils/str_utils.s"
    .include "include/utils/error_utils.s"
    .endif

    .include "include/math/16bit.s"
    .include "include/math/32bit.s"

    .include "include/keyboard.s"
    .include "include/io/io_generic.s"
    .include "include/io/spi.s"

    .include "include/io/sd/init.s"
    .include "include/io/sd/ops.s"
    .include "include/io/fs/partition.s"
    .include "include/io/fs/userland.s"

    .ifndef NO_GPU
    .include "include/io/graphic/graphic.s"
    .include "include/io/graphic/io_graphic.s"
    .endif

    .ifndef NO_LCD
    .include "include/io/lcd/lcd_8bit.s"
    .include "include/io/lcd/io_lcd.s"
    .endif
    
    .ifndef NO_UART
    .include "include/io/uart/uart.s"
    .include "include/io/uart/io_uart.s"
    .endif

    .ifndef BASIC
    .include "include/vectors.s"
    .endif

    .include "include/keymap.s"

    .org $FFFA
    .word nmi
    .word reset
    .word irq
