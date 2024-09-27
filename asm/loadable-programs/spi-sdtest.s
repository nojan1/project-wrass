    .include "setup.s"

    jsr sys_newline    

    jsr spi_init

    lda #((0 << 4) | 2)
    sta SPI_CONFIG
    jsr spi_clock_inactive

    jsr sd_dummy_boot_pulses
    jsr sd_cmd0

    jsr check_and_print_error

    jsr sys_puthex
    jsr sys_newline    

    rts ; Return to monitor

putc=sys_putc
newline=sys_newline
puthex=sys_puthex

    .include "../kernel/include/errors.s"
    .include "../kernel/include/utils/error_utils.s"
    .include "../kernel/include/io/spi.s"
    ; .include "../kernel/include/io/fs/pmartition.s"
    .include "../kernel/include/io/sd/init.s"
    ; .include "../kernel/include/io/sd/ops.s"