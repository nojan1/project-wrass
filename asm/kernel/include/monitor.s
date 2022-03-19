read_command_string:
    .string "rread"

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
_monitor_loop_read:
    jsr getc
    beq _monitor_loop_read

    cmp #$0a ; Was enter pressed?
    beq _monitor_loop_command_entered

    jsr putc
    sta COMMAND_BUFFER, x
    inx

    jmp _monitor_loop_read

_monitor_loop_command_entered:
    ldx #0

    ; Load command buffer into param 1
    lda #<COMMAND_BUFFER
    sta STR_PARAM1
    lda #>COMMAND_BUFFER
    sta STR_PARAM1 + 1

_monitor_loop_command_entered_next_command:
    ; Load current command into param 2
    lda commands, x
    sta STR_PARAM2
    inx 
    lda commands, x
    sta STR_PARAM2 + 1

    jsr str_startswith
; brk_after_startswith:
    bne _monitor_loop_command_recieved

    ; Go to next command
    inx
    inx
    inx

    cpx #$10 ; Have we checked the last available command?
    bne _monitor_loop_command_entered_next_command

    jmp _monitor_loop_command_error
     
_monitor_loop_command_recieved:
    ; We have a valid command
    ; Parse out the parameters eventually
    inx ; num parameters
    inx ; firt part of handler address

brk_before_jump:
    jmp (commands, x)

_command_exuction_complete:
    jmp monitor_loop

bad_command_string:
    .string "Bad command"

_monitor_loop_command_error:
    jsr newline

    lda #<bad_command_string
    sta STR_PARAM1
    lda #>bad_command_string
    sta STR_PARAM1 + 1

    jsr putstr
    jsr newline

    jmp monitor_loop


read_command_implementation:
; brk_entered_read_command:
    nop
    rti

write_command_implementation:
    rti

jump_command_implementation:
    rti