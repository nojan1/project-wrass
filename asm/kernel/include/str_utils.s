; Check if the string (null terminated) in STR_PARAM1 starts with the string (null terminated) in STR_PARAM2 
; The check will abort if STR_PARAM2 contains a space
; Returs the amount of characters that was the same in A, or 0 if there was no match

str_startswith: 
    phy
    sei
        ldy #0

_str_startswith_loop:
        lda (STR_PARAM1), y
        beq _str_startswith_match ; End of string, if we got here consider them the same

        cmp #$20 ; Got space, consider this the same as end of string
        beq _str_startswith_match

        cmp (STR_PARAM2), y
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
    cli
    rts