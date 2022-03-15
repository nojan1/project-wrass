; Check if the string (null terminated) in STR_PARAM1 starts with the string (null terminated) in STR_PARAM2 

str_startswith: 
    phy
    sei
        ldy #0

_str_startswith_loop:
        lda (STR_PARAM2), y
        cmp #0 ; End of string, if we got here consider them the same
brk_startswith_loop_param2_load:
        beq _str_startswith_exit

        cmp (STR_PARAM1), y
        bne _str_startswith_exit

        iny
        jmp _str_startswith_loop

_str_startswith_exit:
    cli
    ply 
    rts