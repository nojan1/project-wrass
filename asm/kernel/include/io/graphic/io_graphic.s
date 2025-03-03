GPU_LINE_BYTES = 64
GPU_TEXT_LINES = 30

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

    ldy CURRENT_LINE
    cpy #GPU_TEXT_LINES
    bne _gpu_newline_not_at_bottom
    ; We have reach the bottom of the screen
    ; We should do something smart here like scrolling the screen....

    ; But for now just jump to the first line beacause cheat
    ldy #0
    jmp _gpu_newline_done

_gpu_newline_not_at_bottom:
    iny
    
_gpu_newline_done:
    ldx #0
    jsr gpu_goto_position
 
    ply
    plx
    rts

; Advance the framebuffer address to the location reference by x and y
gpu_goto_position:
    pha

    stx CURRENT_COLUMN
    sty CURRENT_LINE
; b-rk before mul
;     lda #64
;     sta TERM_16_1_LOW
;     lda #0
;     sta TERM_16_1_HIGH
;     sta TERM_16_2_HIGH
;     sty TERM_16_2_LOW

;     jsr mul_16
; ; b-rk after mul
;     stx TERM_16_2_LOW
;     jsr add_16
; ; b-rk after add
;     lda TERM_16_1_HIGH
;     sta GRAPHICS_ADDR_HIGH
;     lda TERM_16_1_LOW
;     sta GRAPHICS_ADDR_LOW

    stx GRAPHICS_ADDR_LOW ; We can use x as the initial framebuffer offset since it is first in memory
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH

    tya
    tax

    ldy #GPU_LINE_BYTES ; Width of single line of full ressolution
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
