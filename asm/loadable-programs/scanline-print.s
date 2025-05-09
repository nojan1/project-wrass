

    .include "setup.s"

    lda #0
    ldy #%00010110
    jsr sys_clear_screen

    stz GRAPHICS_ADDR_HIGH

    lda #19
    sta GRAPHICS_ADDR_LOW
    
    lda #64
    sta GRAPHICS_INCREMENT

    ldx #32
    lda #128
draw_loop:
    sta GRAPHICS_DATA
    dex
    bne draw_loop

    lda #1
    sta GRAPHICS_INCREMENT

loop:
    ldy GRAPHICS_SCANLINE_LOW
    lda .sinetable, y

    and #$80
    bne loop

    lda .sinetable, y    
    sta GRAPHICS_XOFFSET

    ; lda GRAPHICS_SCANLINE_HIGH
    ; jsr sys_puthex

    ; lda GRAPHICS_SCANLINE_LOW
    ; jsr sys_puthex

    bra loop


.sinetable:
    .db 0, 8, 9, 1, -7, -9, -2, 6, 9, 4, -5, -9, -5, 4, 9, 6
    .db -2, -9, -7, 1, 9, 8, 0, -8, -9, -1, 7, 9, 2, -6, -9, -4
    .db 5, 9, 5, -4, -9, -6, 2, 9, 7, -1, -9, -8, 0, 8, 9, 1
    .db -7, -9, -2, 6, 9, 3, -5, -9, -5, 4, 9, 6, -3, -9, -7, 1
    .db 9, 8, 0, -8, -8, -1, 7, 9, 2, -6, -9, -3, 5, 9, 5, -4
    .db -9, -6, 3, 9, 7, -1, -9, -8, 0, 8, 8, 1, -7, -9, -2, 6
    .db 9, 3, -5, -9, -5, 4, 9, 6, -3, -9, -7, 1, 9, 8, 0, -8
    .db -8, 0, 7, 9, 2, -6, -9, -3, 5, 9, 4, -4, -9, -6, 3, 9
    .db 7, -1, -9, -8, 0, 8, 8, 0, -7, -9, -2, 6, 9, 3, -5, -9
    .db -4, 4, 9, 6, -3, -9, -7, 2, 9, 8, 0, -8, -8, 0, 7, 9
    .db 2, -7, -9, -3, 5, 9, 4, -4, -9, -6, 3, 9, 7, -2, -9, -8
    .db 0, 8, 8, 0, -8, -9, -2, 7, 9, 3, -6, -9, -4, 4, 9, 5
    .db -3, -9, -7, 2, 9, 7, 0, -8, -8, 0, 8, 9, 2, -7, -9, -3
    .db 6, 9, 4, -4, -9, -5, 3, 9, 6, -2, -9, -7, 0, 8, 8, 0
    .db -8, -9, -1, 7, 9, 3, -6, -9, -4, 4, 9, 5, -3, -9, -6, 2
    .db 9, 7, 0, -8, -8, 0, 8, 9, 1, -7, -9, -3, 6, 9, 4, -5

