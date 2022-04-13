display_init:
    lda #1
    sta GRAPHICS_INCREMENT
    lda #$C0
    sta GRAPHICS_ADDR_HIGH
    lda #0
    sta GRAPHICS_ADDR_LOW

    rts


; Copy sprite data from 