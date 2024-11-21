sd_command_implementation:
    nop
    jsr sd_dump_mbr
    jmp _command_execution_complete