
; Send the byte currently in A out on the uart, will wait for buffer to be non full
uart_sendbyte:
   jsr uart_waitsend

   sta UART_TRANSMIT
   rts

uart_waitsend:
   pha
_uart_transmit_buffer_full:
   lda UART_STATUS
   and UART_TRANSMIT_BUFFER_FULL
   bne _uart_transmit_buffer_full

   pla
   rts
