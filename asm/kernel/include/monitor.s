read_command_string:
    .string "read"

write_command_string:
    .string "write"

jump_command_string:
    .string "jump"

commands:
    ; read <addr> <count>
    .word read_command_string ; command string
    .byte 2 ; num parameters
    .word read_command_implementation

    ; write <addr> <value>
    .word write_command_string ; command string
    .byte 2 ; num parameters
    .word write_command_implementation

    ; jump <addr>
    .word jump_command_string ; command string
    .byte 1 ; num parameters
    .word jump_command_implementation


; Enter monitor REPL
monitor_loop:
    lda #">"
    jsr putc
    
    ldx #0
monitor_loop_read:
    jsr getc
    beq monitor_loop_read

    cmp #$0a ; Was enter pressed?
    beq monitor_loop_command_entered

    jsr putc
    sta COMMAND_BUFFER, x
    inx

    jmp monitor_loop_read

monitor_loop_command_entered:
    ldx #0

    ; Load command buffer into param 1
    lda #<COMMAND_BUFFER
    sta STR_PARAM1
    lda #>COMMAND_BUFFER
    sta STR_PARAM1 + 1

    ; Load current command into param 2
    lda commands, x
    sta STR_PARAM2
brk_loaded_lowbyte:
    inx 
    lda commands, x
    sta STR_PARAM2 + 1
brk_loaded_highbyte:

    jsr str_startswith
brk_return_from_startswith:


    jmp monitor_loop



read_command_implementation:
    rti

write_command_implementation:
    rti

jump_command_implementation:
    rti