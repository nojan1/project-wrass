sd_command_implementation:
    nop
    jsr init_sd
    jmp _command_execution_complete