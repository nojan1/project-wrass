GPU_LINE_BYTES = 64
GPU_TEXT_LINES = 30
GPU_TEXT_COLUMNS = 40

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
    sta GRAPHICS_DATA
    rts

; Put newline into output
gpu_newline:
    pha
    phx
    phy

    ldy CURRENT_LINE
    cpy #GPU_TEXT_LINES
    bne _gpu_newline_not_at_bottom
    ; We have reach the bottom of the screen
    ; Copy every line up one step 

    ldy #0
_gpu_newline_next_line:
    ldx #0
_gpu_newline_next_char:
    iny ; Look on the line below for the value we wanna copy
    jsr goto_tilemap_x_y
    lda GRAPHICS_DATA ; Read value to keep

    dey ; Go back up to the current line for storing it
    jsr goto_tilemap_x_y
    sta GRAPHICS_DATA ; Store it in its new place

    inx
    cpx #GPU_TEXT_COLUMNS
    bne _gpu_newline_next_char

    iny ; Updated the next line
    cpy #GPU_TEXT_LINES-1
    bne _gpu_newline_next_line


    ; Now clear the bottom line to make printing prettier
    ; dey
    ldx #0
    jsr goto_tilemap_x_y
    lda #CHARACTER_DEFAULT
_keep_clearing:
    sta GRAPHICS_DATA
    inx
    cpx #GPU_TEXT_COLUMNS
    bne _keep_clearing
    bra _gpu_newline_done

_gpu_newline_not_at_bottom:
    iny
    sty CURRENT_LINE
    
_gpu_newline_done:
    ldx #0
    jsr goto_tilemap_x_y
 
    ply
    plx
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
