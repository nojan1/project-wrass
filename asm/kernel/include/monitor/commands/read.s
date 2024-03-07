DEFAULT_COUNT = 8

read_command_implementation:
    nop
    jsr newline   
    ldy PARAM_16_2 ; Byte offset (lower address)

    ; Check if a count was provided, if not set it to default
    lda PARAM_16_3
    bne .new_row
    lda #DEFAULT_COUNT
    sta PARAM_16_3

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
    bne .read_byte_no_lower_wrap_around
    inc PARAM_16_2 + 1 ; Increment the high part because lower part wrapped around

.read_byte_no_lower_wrap_around:
    inx

    dec PARAM_16_3
    beq .done

    cpx #8
    bne .read_byte_loop

    jsr newline
    jmp .new_row

.done:
    jmp _command_execution_complete