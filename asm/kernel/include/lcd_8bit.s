E  = %10000000
RW = %01000000
RS = %00100000

lcd_wait:
  pha
  lda #%00000000  ; Port B is input
  sta LCD_DDRB
lcdbusy:
  lda #RW
  sta LCD_PORTA
  lda #(RW | E)
  sta LCD_PORTA
  lda LCD_PORTB
  and #%10000000
  bne lcdbusy
  
  lda #RW
  sta LCD_PORTA
  lda #%11111111  ; Port B is output
  sta LCD_DDRB
  pla
  rts

lcd_instruction:
  jsr lcd_wait
  sta LCD_PORTB
  lda #0         ; Clear RS/RW/E bits
  sta LCD_PORTA
  lda #E         ; Set E bit to send instruction
  sta LCD_PORTA
  lda #0         ; Clear RS/RW/E bits
  sta LCD_PORTA
  rts 

print_char:
  jsr lcd_wait
  sta LCD_PORTB
  lda #RS         ; Set RS; Clear RW/E bits
  sta LCD_PORTA
  lda #(RS | E)   ; Set E bit to send instruction
  sta LCD_PORTA
  lda #RS         ; Clear E bits
  sta LCD_PORTA
  rts