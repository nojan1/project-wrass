load_instruction_string:
    .string "Reading HEX bytes, end with \n"

checksum_error_string:
    .string "Error: LOAD_CHECKSUM_MISMATCH"

checksum_error_second_line_string:
    .string "Got: "

load_command_implementation:
    nop
    sei

    jsr newline
    putstr_addr load_instruction_string
    jsr newline

    ; Used for checksum
    lda #0
    sta VAR_8BIT_2
    sta ERROR

    ; Destination address in PARAM_16_2
    ldy PARAM_16_2 ; Y will be used for offset

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

    ; Update checksum
    eor VAR_8BIT_2
    sta VAR_8BIT_2

    iny
    bne .load_read_1
    inc PARAM_16_2 + 1 ; Y wrapped around, increment the address
    ldy #0
    jmp .load_read_1
    
.load_done:
    jsr check_and_print_error

    lda PARAM_16_3
    beq .checksum_check_done

    cmp VAR_8BIT_2
    beq .checksum_check_done

    jsr newline
    putstr_addr checksum_error_string

    jsr newline
    putstr_addr checksum_error_second_line_string
    lda VAR_8BIT_2
    jsr puthex

.checksum_check_done:
    cli
    jmp _command_execution_complete
