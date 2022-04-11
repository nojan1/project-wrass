; Check if the string (null terminated) in PARAM_16_1 starts with the string (null terminated) in PARAM_16_2 
; The check will abort if PARAM_16_2 contains a space
; Returs the amount of characters that was the same in A, or 0 if there was no match

str_startswith: 
    phy
        ldy #0

_str_startswith_loop:
        lda (PARAM_16_1), y
        beq _str_startswith_match ; End of string, if we got here consider them the same

        cmp #$20 ; Got space, consider this the same as end of string
        beq _str_startswith_match

        cmp (PARAM_16_2), y
        bne _str_startswith_no_match

        iny
        jmp _str_startswith_loop

_str_startswith_match:
    tya
    jmp _str_startswith_exit

_str_startswith_no_match:
    lda #0

_str_startswith_exit:
    ply 
    rts


; Read a byte in hex from PARAM_16_1 and return it in A
; Y will be used as the starting offset
; If a null or space is encountered a zero will be returned
str_readhex:
    phx
    
    ; Upper 4 bits
    jsr str_readhexchar
    asl
    asl
    asl
    asl
    sta VAR_8BIT_1

    ; Lower 4 bits
    iny
    jsr str_readhexchar
    clc
    adc VAR_8BIT_1

    plx
    rts

; Read a hex char from PARAM_16_1 and return it in A
; Y will be used as the starting offset
; If a null or space is encountered a zero will be returned
str_readhexchar:
    lda (PARAM_16_1), y
    beq .return_zero

    cmp #$20; Space
    beq .return_zero

    jsr convert_hex
    rts    

.return_zero:
    lda #0
    rts