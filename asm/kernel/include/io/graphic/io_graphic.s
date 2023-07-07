; Transform ascii character i A into screencode and put into A
c_to_sc:
    sec
    sbc #32
    rts

; Put character from A into output
; ** Note this will be where the current address in the GPU just happens to be, it also assumes that the increment is 1! **
gpu_putc:
    pha
    jsr c_to_sc
    jsr gpu_putsc
    pla
    rts

; Put screen code from A into output
; ** Note this will be where the current address in the GPU just happens to be, it also assumes that the increment is 1! **
gpu_putsc:
    inc CURRENT_COLUMN
    sta GRAPHICS_DATA
    rts

; Put newline into output
gpu_newline:
    phx
    phy

    ldx #0

    ldy CURRENT_LINE
    iny

    jsr gpu_goto_position
 
    ply
    plx
    rts

; Advance the framebuffer address to the location reference by x and y
gpu_goto_position:
    pha

    stx CURRENT_COLUMN
    sty CURRENT_LINE
; brk before mul
;     lda #64
;     sta TERM_16_1_LOW
;     lda #0
;     sta TERM_16_1_HIGH
;     sta TERM_16_2_HIGH
;     sty TERM_16_2_LOW

;     jsr mul_16
; ; brk after mul
;     stx TERM_16_2_LOW
;     jsr add_16
; ; brk after add
;     lda TERM_16_1_HIGH
;     sta GRAPHICS_ADDR_HIGH
;     lda TERM_16_1_LOW
;     sta GRAPHICS_ADDR_LOW

    stx GRAPHICS_ADDR_LOW ; We can use x as the initial framebuffer offset since it is first in memory
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH

    tya
    tax

    ldy #64 ; Width of single line of full ressolution
    jsr advance_graphic_address

    pla
    rts

; Remove the last character at the current GPU address
gpu_ereasec: 
    pha
    dec GRAPHICS_ADDR_LOW

    lda #$0
    sta GRAPHICS_INCREMENT
    sta GRAPHICS_DATA

    lda #1
    sta GRAPHICS_INCREMENT

    pla
    rts
