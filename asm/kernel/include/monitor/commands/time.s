
time_command_implementation:
    nop
    jsr newline

    ldx #(DS1306_YEAR)
    jsr ds1306_command
    jsr puthex

    lda #'-'
    jsr putc

    ldx #(DS1306_MONTH)
    jsr ds1306_command
    jsr puthex

    lda #'-'
    jsr putc

    ldx #(DS1306_DATE)
    jsr ds1306_command
    jsr puthex

    lda #' '
    jsr putc

    ldx #(DS1306_HOURS)
    jsr ds1306_command
    jsr puthex

    lda #':'
    jsr putc

    ldx #(DS1306_MINUTES)
    jsr ds1306_command
    jsr puthex

    lda #':'
    jsr putc

    ldx #(DS1306_SECONDS)
    jsr ds1306_command
    jsr puthex

    jsr newline
  
    jmp _command_execution_complete
