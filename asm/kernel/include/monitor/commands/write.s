wrote_string: .string "Wrote "
to_string: .string " to "

write_command_implementation:
    nop
    jsr newline
    putstr_addr wrote_string
    lda PARAM_16_3
    jsr puthex
    putstr_addr to_string
    lda PARAM_16_2 + 1
    jsr puthex
    lda PARAM_16_2
    jsr puthex
   
    lda PARAM_16_3
    
    ldy #0
    sta (PARAM_16_2),y
    jmp _command_execution_complete
