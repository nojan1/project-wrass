

    .include "setup.s"

    lda #0
    ldy #%00010110
    jsr sys_clear_screen

    rts
loop:
    stz GRAPHICS_ADDR_LOW

    lda GRAPHICS_SCANLINE_HIGH
    jsr sys_puthex

    lda GRAPHICS_SCANLINE_LOW
    jsr sys_puthex

    bra loop
