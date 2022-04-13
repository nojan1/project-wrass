; Put character from A into output
putc:
    inc CURRENT_COLUMN
    ; jsr sync_graphic_address
    sta GRAPHICS_DATA
    rts

; Put newline into output
newline:
    pha

    lda #0
    sta CURRENT_COLUMN
    inc CURRENT_LINE

    jsr sync_graphic_address
.exit:
    pla
    rts

; Make sure the address pointers sync up with the cursor variables
sync_graphic_address:
    phx
    phy
    pha

    ldx CURRENT_LINE
    cpx #60
    beq .max_row_reached

.newline_offset_calculation_loop:
    cpx #0
    beq .newline_offset_calculated
    
    clc
    adc #80

    bcc .no_upper_address_inc
    iny

.no_upper_address_inc:
    dex
    jmp .newline_offset_calculation_loop

.newline_offset_calculated:
    clc
    adc CURRENT_COLUMN

    sta GRAPHICS_ADDR_LOW

    lda #$C0
    sta GRAPHICS_ADDR_HIGH

    tya
    clc
    adc GRAPHICS_ADDR_HIGH
    sta GRAPHICS_ADDR_HIGH

.max_row_reached:
    ; How to handle ????

    pla
    ply
    plx    
    rts