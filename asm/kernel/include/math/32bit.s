; Produces addidtion between {TERM_32_1_4,TERM_32_1_3,TERM_32_1_2,TERM_32_1_1} and {TERM_32_2_4,TERM_32_2_3,TERM_32_2_2,TERM_32_2_1}
; Stores result in {TERM_32_1_4,TERM_32_1_3,TERM_32_1_2,TERM_32_1_1} 
add_32:
    pha
    clc

    lda TERM_32_1_1
    adc TERM_32_2_1
    sta TERM_32_1_1

    lda TERM_32_1_2
    adc TERM_32_2_2
    sta TERM_32_1_2

    lda TERM_32_1_3
    adc TERM_32_2_3
    sta TERM_32_1_3

    lda TERM_32_1_4
    adc TERM_32_2_4
    sta TERM_32_1_4

    pla
    rts

; Produces subtraction between {TERM_32_1_4,TERM_32_1_3,TERM_32_1_2,TERM_32_1_1} and {TERM_32_2_4,TERM_32_2_3,TERM_32_2_2,TERM_32_2_1}
; Stores result in {TERM_32_1_4,TERM_32_1_3,TERM_32_1_2,TERM_32_1_1}
sub_32:
    pha
    sec

    lda TERM_32_1_1
    sbc TERM_32_2_1
    sta TERM_32_1_1

    lda TERM_32_1_2
    sbc TERM_32_2_2
    sta TERM_32_1_2
    
    lda TERM_32_1_3
    sbc TERM_32_2_3
    sta TERM_32_1_3

    lda TERM_32_1_4
    sbc TERM_32_2_4
    sta TERM_32_1_4

    pla
    rts