E  = %10000000
RW = %01000000
RS = %00100000

lcd_display_init:
  ; LCD SETUP
  lda #%11111111 ; Set all pins on port B to output
  sta LCD_DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta LCD_DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction_no_wait
  lda #%00001100 ; Display on; cursor off; blink off
  jsr lcd_instruction_no_wait
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction_no_wait
  lda #$00000001 ; Clear display
  jsr lcd_instruction_no_wait
  rts

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
lcd_instruction_no_wait:
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
