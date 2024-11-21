    .include "setup.s"

    jsr sys_newline

    ; SET UP SPI
    jsr spi_init

    lda #((0 << 4) | 2)
    sta SPI_CONFIG
    jsr spi_clock_inactive
    
    ; Talk to dummy device...
    lda #(SPI_DEVICES_ENABLED | (2 << 1))    
    jsr spi_set_device

    ldx #4

.send_next:
    dex
    beq .done

    putstr_addr sending_string
    lda data, x
    jsr sys_puthex
    jsr sys_newline

    jsr spi_transcieve

    cmp data, x
    bne .no_match
    putstr_addr match_string
    jsr sys_newline
    bra .send_next
.no_match
    pha
    putstr_addr nomatch_string
    pla
    jsr sys_puthex
    jsr sys_newline
    bra .send_next

.done
    rts

sending_string:
    .string "Sending "
nomatch_string:
    .string "Got bad data, "
match_string:
    .string "Data matches!"

data:
    .db $AA, $55, $FF, $0 

    .include "../kernel/include/io/spi.s"