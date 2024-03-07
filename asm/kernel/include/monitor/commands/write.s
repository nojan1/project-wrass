write_command_implementation:
    nop
    lda PARAM_16_3
    ldy #0
    sta (PARAM_16_2),y
    jmp _command_execution_complete