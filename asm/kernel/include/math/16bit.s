; Produces addidtion between {TERM_16_1_HIGH,TERM_16_1_LOW} and {TERM_16_2_HIGH,TERM_16_2_LOW}
; Stores result in {TERM_16_1_HIGH,TERM_16_1_LOW} 
add_16:
    pha
    clc

    lda TERM_16_1_LOW
    adc TERM_16_2_LOW
    sta TERM_16_1_LOW

    lda TERM_16_1_HIGH
    adc TERM_16_2_HIGH
    sta TERM_16_1_HIGH

    pla
    rts

; Produces subtraction between {TERM_16_1_HIGH,TERM_16_1_LOW} and {TERM_16_2_HIGH,TERM_16_2_LOW}
; Stores result in {TERM_16_1_HIGH,TERM_16_1_LOW} 
sub_16:
    pha
    sec

    lda TERM_16_1_LOW
    sbc TERM_16_2_LOW
    sta TERM_16_1_LOW

    lda TERM_16_1_HIGH
    sbc TERM_16_2_HIGH
    sta TERM_16_1_HIGH

    pla
    rts