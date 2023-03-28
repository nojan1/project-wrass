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

; Produces multiplication between {TERM_16_1_HIGH,TERM_16_1_LOW} and {TERM_16_2_HIGH,TERM_16_2_LOW}
; Stores result in {TERM_16_1_HIGH,TERM_16_1_LOW} 
mul_16:
    pha
    phx
    phy

    ldx TERM_16_2_LOW
    ldy TERM_16_2_HIGH

    lda TERM_16_1_LOW
    sta TERM_32_1_3
    lda TERM_16_1_HIGH
    sta TERM_32_1_4

    cpx #0
    beq _check_upper

_mul_loop:
    clc

    lda TERM_16_1_LOW
    adc TERM_32_1_3
    sta TERM_16_1_LOW

    lda TERM_16_1_HIGH
    adc TERM_32_1_4
    sta TERM_16_1_HIGH

    dex
    cpx #1
    bne _mul_loop

_check_upper:
    ; Lower byte is at 0, check the upper byte
    cpy #0
    beq _done

    ; We are not done, decrement upper byte and reset lower
    dey
    ldx TERM_16_2_LOW
    jmp _mul_loop

_done:
    ply
    plx
    pla
    rts