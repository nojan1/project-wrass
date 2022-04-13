; Put character from A into output
putc:
    pha
        jsr print_char ; Temporary, refactor to remove double call
    pla
    rts

; Put newline into output
newline:
    pha
    phx
    
    lda CURRENT_LINE
    clc
    adc #1
    cmp #NUM_ROWS
    
    bne _newline_not_max_row
    lda #0

_newline_not_max_row:
    sta CURRENT_LINE

    tax
    lda #0
_newline_offset_calculation_loop:
    cpx #0
    beq _newline_offset_calculated
    
    clc
    adc #NUM_COLS ; Add the number of characters on each LCD row
    dex
    jmp _newline_offset_calculation_loop

_newline_offset_calculated
    ora #$80 ; Set 7th bit
    jsr lcd_instruction

    plx
    pla
    rts