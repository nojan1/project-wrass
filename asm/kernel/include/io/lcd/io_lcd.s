; Put character from A into output
lcd_putc:
    pha
        jsr print_char ; Temporary, refactor to remove double call
    pla
    rts

; Put newline into output
lcd_newline:
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

    ; A now hold the current line we should be on
    jsr lcd_goto_current_line ; go there

    ; Overwrite the entire row with space
    pha
    lda #$20
    ldx #NUM_COLS 
.print_next:
    jsr putc
    dex
    bne .print_next

    pla
    jsr lcd_goto_current_line ; Go back to start of row

    pla
    plx
    rts

lcd_goto_current_line:
    pha
    
    clc
    ror a
    ror a
    
    ora #$80 ; Set 7th bit
    jsr lcd_instruction

    pla
    rts

lcd_ereasec:
    rts
