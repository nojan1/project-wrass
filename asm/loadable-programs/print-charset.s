    .include "setup.s"

    lda #0
.loop:
    jsr sys_putc
    tax
    inx
    txa
    bne .loop

    rts