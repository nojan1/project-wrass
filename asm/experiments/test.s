  .org $8000

reset:
  ldx #$ff
  txs 

  lda #%11111111 ; Set all pins on port B to output
  sta DDRB
  lda #%11100000 ; Set top 3 pins on port A to output
  sta DDRA

  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_instruction
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_instruction
  lda #$00000001 ; Clear display
  jsr lcd_instruction

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  ldy #100
print_wait:
  beq print
  dey
  jmp print_wait

loop:
  jmp loop

message: .asciiz "Hello, world!"

  .include "include/constants.s"
  .include "include/lcd_8bit.s"

  .org $fffc
  .word reset
  .word $0000