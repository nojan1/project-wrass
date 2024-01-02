NUM_COLS=40
NUM_ROWS=2

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
   jsr gpu_putc
   .endif

   .ifndef NO_UART 
   ; Just send a byte out on the UART, no wait just hope the buffer doesn't overflow
   sta UART_TRANSMIT
   .endif

   .ifndef NO_LCD 
   jsr lcd_putc
   .endif

   rts

; Put newline onto configured outputs
newline:
   .ifndef NO_GPU
    jsr gpu_newline
   .endif

   .ifndef NO_UART
   pha
   lda #13
   sta UART_TRANSMIT
   lda #10
   sta UART_TRANSMIT
   pla
   .endif

   .ifndef NO_LCD
   jsr lcd_newline
   .endif

   rts
