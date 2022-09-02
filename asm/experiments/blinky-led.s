PORTB = $A000
PORTA = PORTB + 1 
DDRB = PORTA + 1
DDRA = DDRB + 1
   
    .org $C000
reset:
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    lda #$FF ; Set all pins on PORTB to be output
    sta DDRB

    lda #1 ; Set firs bit to 1
loop:
    sta PORTB
    rol a ; Rotate result left
    nop
    nop
    nop
    nop
    nop ; Wait a while xD
    jmp loop


    .org $FFFC
    .word reset 
    .word 0
