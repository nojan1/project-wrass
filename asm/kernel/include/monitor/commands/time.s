
time_command_implementation:
    jsr sys_newline

    ldx #(DS1306_YEAR)
    jsr ds1306_command
    jsr sys_puthex

    lda #'-'
    jsr sys_putc

    ldx #(DS1306_MONTH)
    jsr ds1306_command
    jsr sys_puthex

    lda #'-'
    jsr sys_putc

    ldx #(DS1306_DATE)
    jsr ds1306_command
    jsr sys_puthex

    lda #' '
    jsr sys_putc

    ldx #(DS1306_HOURS)
    jsr ds1306_command
    jsr sys_puthex

    lda #':'
    jsr sys_putc

    ldx #(DS1306_MINUTES)
    jsr ds1306_command
    jsr sys_puthex

    lda #':'
    jsr sys_putc

    ldx #(DS1306_SECONDS)
    jsr ds1306_command
    jsr sys_puthex
  
    jsr sys_newline

    jmp _command_execution_complete
