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