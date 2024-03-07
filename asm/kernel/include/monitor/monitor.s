read_command_string:
    .string "read"

write_command_string:
    .string "write"

jump_command_string:
    .string "jump"

load_command_string:
    .string "load"

sd_command_string:
    .string "sd"


commands:
    ; read <addr> [count]
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

    ; load <addr>
    .word load_command_string ; command string
    .byte 1 ; num parameters
    .word load_command_implementation

    ; sd
    .word sd_command_string ; command string
    .byte 0 ; num parameters
    .word sd_command_implementation
commands_end:

monitor_loop_start:
    jsr print_banner

; Enter monitor REPL
monitor_loop:
    ; Clean out params used for command line parameters
    lda #0
    sta PARAM_16_1
    sta PARAM_16_1 + 1
    sta PARAM_16_2
    sta PARAM_16_2 + 1
    sta PARAM_16_3
    sta PARAM_16_3 + 1

    ; Ensure command buffer is all 0
    ldx #0
.command_buffer_not_clean:
    sta COMMAND_BUFFER, x
    inx
    bne .command_buffer_not_clean

    cli
    lda #">"
    jsr putc
    
    ldx #0
.read:
    jsr getc
    bcc .read

    cmp #$0a ; Was enter pressed?
    beq .command_entered

    cmp #$0d
    beq .command_entered

    cmp #$08 ; Backspace
    beq .erase

    jsr putc
    sta COMMAND_BUFFER, x
    inx
    
    jmp .read

.erase:
    cpx #0
    beq .read

    dex
    lda #0
    sta COMMAND_BUFFER, x
    jsr ereasec
    jmp .read

.command_entered:
    sei
    lda #0
    sta COMMAND_BUFFER, x ; Put null terminator into command
    ldx #0

    ; Load command buffer into param 1
    lda #<COMMAND_BUFFER
    sta PARAM_16_1
    lda #>COMMAND_BUFFER
    sta PARAM_16_1 + 1

.next_command:
    ; Load current command into param 2
    lda commands, x
    sta PARAM_16_2
    inx
    lda commands, x
    sta PARAM_16_2 + 1
    jsr str_startswith
    cmp #0

    bne .command_recieved

    ; Go to next command
    inx
    inx
    inx
    inx

    cpx #(commands_end - commands) ; Have we checked the last available command?
    bcc .next_command

    jmp _monitor_loop_command_error
     
.command_recieved:
    ; We have a valid command
    ; Parse out the parameters
    inx ; num parameters
    phx
    
    tay
    lda commands, x
    beq .parameters_parsed
    tax

    iny
    jsr str_readhex
    sta PARAM_16_2 + 1

    iny
    jsr str_readhex
    sta PARAM_16_2

    dex
    beq .parameters_parsed
    
    iny
    iny
    jsr str_readhex
    sta PARAM_16_3

    dex
    beq .parameters_parsed
    
.parameters_parsed
    plx
     
    inx
    inx ; second address byte to handler
    lda commands, x
    pha
    dex ; first address byte to handler
    lda commands, x
    pha
    rts

_command_execution_complete:
    jsr newline
    jmp monitor_loop

bad_command_string:
    .string "Bad command"

_monitor_loop_command_error:
    jsr newline
    putstr_addr bad_command_string
    jsr newline

    jmp monitor_loop

    .include "include/monitor/commands/read.s"
    .include "include/monitor/commands/write.s"
    .include "include/monitor/commands/jump.s"
    .include "include/monitor/commands/load.s"
    .include "include/monitor/commands/sd.s"