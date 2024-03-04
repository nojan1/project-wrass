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
    ; read <addr>
    .word read_command_string ; command string
    .byte 1 ; num parameters
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
    
; Do old school jumping instead
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

read_command_implementation:
    nop
    jsr newline   
    ldy PARAM_16_2 ; Byte offset (lower address)

.new_row:
    ldx #1
    lda PARAM_16_2, x
    jsr puthex
    ldx #0 ; Column count
    tya
    jsr puthex

    lda #":"
    jsr putc
    lda #" "
    jsr putc

.read_byte_loop:
    lda (PARAM_16_2), y
    jsr puthex

    lda #" "
    jsr putc

    iny
    inx

    cpy #255
    beq .done

    cpx #16
    bne .read_byte_loop

    jsr newline
    jmp .new_row

.done:
    jmp _command_execution_complete

write_command_implementation:
    nop
; brk write-command
    lda PARAM_16_3
    ldy #0
    sta (PARAM_16_2),y
    jmp _command_execution_complete

jump_command_implementation:
    nop

    ; Put the return point on the stack
    lda #>(_command_execution_complete - 1)
    pha
    lda #<(_command_execution_complete - 1)
    pha

    ; Put the user provided address as return address on stack
    lda PARAM_16_2        ; Load low part of address
    sec
    sbc #1                ; Subtract 1 to account for rts incrementing PC
    tay                   ; Move to Y 
    lda PARAM_16_2 + 1    ; Load high part
    sbc #0                ; Subtract if carry set
    pha                   ; Push high part on stack
    phy                   ; Push low part on stack

    ; "Return" to the user provided address
    rts

load_instruction_string:
    .string "Reading HEX bytes, end with \n"

load_command_implementation:
    nop
    jsr newline
    putstr_addr load_instruction_string
    jsr newline

    ; Destination address in PARAM_16_2
    ldy #0 ; Y will be used for offset

    ; Read first hex char
.load_read_1:
    jsr getc
    bcc .load_read_1
    cmp #10 ;If we get a newline stop reading
    beq .load_done
    cmp #13
    beq .load_done

    jsr convert_hex

    ; A now contains half a byte worth of data, shift the lower 4 bits to top
    asl 
    asl
    asl
    asl
    sta VAR_8BIT_1

    ; Read second hex char
.load_read_2:
    jsr getc
    bcc .load_read_2
    cmp #10 ; If we get a newline stop reading
    beq .load_done
    cmp #13
    beq .load_done

    jsr convert_hex

    ; OR the two parts together
    ora VAR_8BIT_1

    ; Write byte to ram
    sta (PARAM_16_2), y
    iny
    bne .load_read_1
    inc PARAM_16_2 + 1 ; Y wrapped around, increment the address
    ldy #0
    jmp .load_read_1
    
.load_done:
    jmp _command_execution_complete

sd_command_implementation:
    nop
    jsr init_sd
    jmp _command_execution_complete