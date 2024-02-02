uart_putc:
; brk uart-putc
   sta UART_TRANSMIT
   rts

uart_newline:
   rts

uart_ereasec:
  rts
