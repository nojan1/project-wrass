; puts the number stored in A
puthex:
    pha 
    and #0b11110000
    lsr
    lsr
    lsr
    lsr ; A now contains the top 4 bits in the bottom position
    jsr putchex
    pla
    pha 
    and #0b00001111
    jsr putchex
    pla
    rts

; convert the hex number (0-15) stored in A to ascii and calls putc
putchex:
    cmp #9
    bcs .above_9

    clc
    adc #$30
    jsr putc
    rts 

.above_9:
    clc
    adc #($41 - $A)
    jsr putc
    rts

; Convert the hexadecimal character in A into its real value and stores it in A
convert_hex: 
    cmp #$60
    bcs .possibly_lower_character

    cmp #$40
    bcs .possibly_upper_character
    
    cmp #$2F
    bcs .possibly_digit

    jmp .bad_char

.possibly_lower_character
    cmp #$67
    bcs .bad_char

    sec
    sbc #$57
    rts
    
.possibly_upper_character
    cmp #$47
    bcs .bad_char
 
    sec
    sbc #$37
    rts

.possibly_digit
    cmp #$40
    bcs .bad_char

    and #0b00001111 ; The lower 4 bits hold the digit result
    rts

.bad_char:
    ; If we got here the acscii value is not within valid hex range at all
    lda #0
    rts


