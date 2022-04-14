; Put character from A into output
; ** Note this will be where the current address in the GPU just happens to be, it also assumes that the increment is 1! **
putc:
    inc CURRENT_COLUMN
    sta GRAPHICS_DATA
    rts

; Put newline into output
newline:
    phx
    phy

    ldx #0

    ldy CURRENT_LINE
    iny

    jsr goto_position
.exit:
    ply
    plx
    rts

; Advance the framebuffer address to the location reference by x and y
goto_position:
    pha

    stx CURRENT_COLUMN
    sty CURRENT_LINE

    stx GRAPHICS_ADDR_LOW ; We can use x as the initial framebuffer offset since it is first in memory
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH

    tya
    tax

    ldy #80 ; Width of single line
    jsr advance_graphic_address

    pla
    rts

; Remove the last character at the current GPU address
ereasec: 
    pha
    dec GRAPHICS_ADDR_LOW

    lda #$0
    sta GRAPHICS_INCREMENT
    sta GRAPHICS_DATA

    lda #1
    sta GRAPHICS_INCREMENT

    pla
    rts
