uart_putc:
   pha
_uart_putc_check_again:
   lda UART_STATUS
   and #UART_TRANSMIT_BUFFER_FULL
   beq _uart_putc_check_again
   pla
   sta UART_TRANSMIT
   rts

uart_newline:
   pha
   lda #13
   jsr uart_putc
   lda #10
   jsr uart_putc
   pla
   rts

uart_ereasec:
   pha
   lda #8
   jsr uart_putc
   pla
   rts
 
uart_getc:
   lda #UART_RECIEVE_BUFFER_FULL
   bit UART_STATUS

   ; Read buffer has overflowed
   beq _uart_getc_no_overlow
   php
   lda #UART_RECIEVE_BUFFER_OVERFLOW
   sta ERROR
   plp

_uart_getc_no_overlow:
   bpl _uart_getc_no_byte ; High bit not set

   lda UART_RECIEVE
   sec
   jmp _uart_getc_got_byte
_uart_getc_no_byte:
   clc 
_uart_getc_got_byte:
   rts