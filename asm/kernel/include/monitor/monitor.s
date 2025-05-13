read_command_string:
    .string "read"

write_command_string:
    .string "write"

jump_command_string:
    .string "jump"

load_command_string:
    .string "load"

initsd_command_string:
    .string "initsd"

ls_command_string:
    .string "ls"

cd_command_string:
    .string "cd"

cat_command_string:
    .string "cat"

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
    .byte 2 ; num parameters
    .word load_command_implementation

    ; initsd
    .word initsd_command_string ; command string
    .byte 0 ; num parameters
    .word initsd_command_implementation

    ; ls
    .word ls_command_string ; command string
    .byte 0 ; num parameters
    .word ls_command_implementation

    ; cd <name>
    .word cd_command_string ; command string
    .byte 0 ; num parameters, technically there is a string after but that is not a 16 bit number so the monitor won't care
    .word cd_command_implementation

    ; cat <name>
    .word cat_command_string ; command string
    .byte 0 ; num parameters, technically there is a string after but that is not a 16 bit number so the monitor won't care
    .word cat_command_implementation
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

    jmp _monitor_loop_command_not_found
     
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
    ; Add Y to PARAM_16_1 so that handlers can just use the end of the last parsed parameter as "input string"
    iny ; This might be a problem...
    tya
    clc
    adc PARAM_16_1
    sta PARAM_16_1
    lda #0
    adc PARAM_16_1 + 2
    sta PARAM_16_1 + 2

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

_monitor_loop_command_not_found:
    ; No command was found.. if the SD card is initialized we should check for a binary with that name and execute it
    lda SD_CARD_STATUS
    cmp #SD_CARD_INITIALIZED
    bne _monitor_loop_command_error

    ; Okey the SD card is setup.. now to find a binary.. we should be able to just pass the command buffer (in PARAM_16_1) directly
    stz ERROR
    jsr find_file_entry_in_current_directory
    bne _monitor_loop_command_error

    ; We have a file.. check that the file extension is correct
    ldy #8
    lda #"P"
    cmp (TERM_16_1_LOW), y
    bne _monitor_loop_command_error
    iny
    lda #"R"
    cmp (TERM_16_1_LOW), y
    bne _monitor_loop_command_error
    iny
    lda #"G"
    cmp (TERM_16_1_LOW), y
    bne _monitor_loop_command_error

    ; It is a valid program.. at least by extension.
    jsr open_file
    bcs _monitor_loop_command_error

    lda #<PROGRAM_LOAD_ADDRESS
    sta PARAM_16_2
    lda #>PROGRAM_LOAD_ADDRESS
    sta PARAM_16_2 + 1

_monitor_loop_next_chunk:
    jsr read_file
    bcs _monitor_loop_command_error
    cpx #0
    beq _monitor_loop_program_loaded
    ldy #0
_monitor_loop_next_byte:
    ; Read one byte from chunk buffer and put into program memory
    lda (PARAM_16_1), y
    sta (PARAM_16_2), y
    iny
    dex
    bne _monitor_loop_next_byte
    inc PARAM_16_2 ; Increment to use the next 256 byte block in memory
    bra _monitor_loop_next_chunk

_monitor_loop_program_loaded:
    jsr newline ; So that programs don't have to worry about it

    ; Time to execute the loaded program.. first setup the return address
    lda #>(_command_execution_complete - 1)
    pha
    lda #<(_command_execution_complete - 1)
    pha

    ; Then jump to the program
    jmp PROGRAM_LOAD_ADDRESS
    ; ---will never get here

_monitor_loop_command_error:
    jsr newline
    putstr_addr bad_command_string
    jsr newline

    jmp monitor_loop

    .include "include/monitor/commands/read.s"
    .include "include/monitor/commands/write.s"
    .include "include/monitor/commands/jump.s"
    .include "include/monitor/commands/load.s"
    .include "include/monitor/commands/initsd.s"
    .include "include/monitor/commands/fs.s"