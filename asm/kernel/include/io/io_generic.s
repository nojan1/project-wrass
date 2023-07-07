NUM_ROWS = 2
NUM_COLS = 16

; Check for and return an available charactor from the input buffer
; The character will be placed in A
; If no character is available A will be set to 0
getc:
    sei
    phx
    lda READ_POINTER
    cmp WRITE_POINTER
    bne _getc_character_available ;Is the read pointer behind the write pointer?
    lda #$0
    jmp _getc_return

_getc_character_available:
    ldx READ_POINTER
    lda INPUT_BUFFER, x
    inc READ_POINTER

_getc_return:
    plx
    cli
    rts

; Put characters from string in PARAM_16_1 into output
putstr:
    pha
    phy 
    ldy #0

_putstr_loop:
    lda (PARAM_16_1), y
    beq _putstr_end

    jsr putc

    iny
    jmp _putstr_loop

_putstr_end:
    ply
    pla
    rts

; Put character in A onto configured outputs
putc:
   .ifndef NO_GPU
   pha 
   lda IO_CONTROL
   and GPU_OUTPUT
   beq _no_gpu_output
   pla
   jsr gpu_putc
   .endif

_no_gpu_output:
   .ifndef NO_UART
   pha 
   lda IO_CONTROL
   and UART_OUTPUT
   beq _no_uart_output
   pla
   jsr uart_putc
   .endif

_no_uart_output:
   .ifndef NO_LCD
   pha 
   lda IO_CONTROL
   and LCD_OUTPUT
   beq _no_lcd_output
   pla
   jsr lcd_putc
   .endif

_no_lcd_output:
   rts

; Put newline onto configured outputs
newline:
   .ifndef NO_GPU
   pha 
   lda IO_CONTROL
   and GPU_OUTPUT
   beq _newline_no_gpu_output
   pla
   jsr gpu_newline
   .endif

_newline_no_gpu_output:
   .ifndef NO_UART
   pha 
   lda IO_CONTROL
   and UART_OUTPUT
   beq _newline_no_uart_output
   pla
   jsr uart_newline
   .endif

_newline_no_uart_output:
   .ifndef NO_LCD
   pha 
   lda IO_CONTROL
   and LCD_OUTPUT
   beq _newline_no_lcd_output
   pla
   jsr lcd_newline
   .endif

_newline_no_lcd_output:
   rts

; Erease last character from configured outputs
ereasec:
   .ifndef NO_GPU
   pha 
   lda IO_CONTROL
   and GPU_OUTPUT
   beq _ereasec_no_gpu_output
   pla
   jsr gpu_ereasec
   .endif

_ereasec_no_gpu_output:
   .ifndef NO_UART
   pha 
   lda IO_CONTROL
   and UART_OUTPUT
   beq _ereasec_no_uart_output
   pla
   jsr uart_ereasec
   .endif

_ereasec_no_uart_output:
   .ifndef NO_LCD
   pha 
   lda IO_CONTROL
   and LCD_OUTPUT
   beq _ereasec_no_lcd_output
   pla
   jsr lcd_ereasec
   .endif

_ereasec_no_lcd_output:
   rts
