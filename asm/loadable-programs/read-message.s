
    .include "setup.s"

    lda #<filename
    sta PARAM_16_1
    lda #>filename
    sta PARAM_16_1 + 1

    jsr sys_open_file
    bcs .done

    jsr sys_read_file
    bcs .done

    ldy #0
.print_next
    lda (PARAM_16_1), y
    jsr sys_putc
    iny
    dex
    bne .print_next

    jsr sys_newline
.done:
    rts

filename:
    .string "message"