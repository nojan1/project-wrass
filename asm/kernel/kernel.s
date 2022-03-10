    .org $C000

    .include "include/constants.s"
    .include "include/io.s"
    .include "include/lcd_8bit.s"
    .include "include/monitor.s"

irq:
    ; Keyboard interupt, we will assume this is the only thing that can trigger and interupt atm...
    pha
    txa
    pha
        lda IO_VIA2_PORTA
        ldx WRITE_POINTER
        sta INPUT_BUFFER, x
        inc WRITE_POINTER
    pla
    tax
    pla

    rti

nmi:
    nop
    rti

reset:
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER


    ; LCD SETUP
    lda #%11111111 ; Set all pins on port B to output
    sta LCD_DDRB
    lda #%11100000 ; Set top 3 pins on port A to output
    sta LCD_DDRA

    lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction
    lda #%00001110 ; Display on; cursor on; blink off
    jsr lcd_instruction
    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr lcd_instruction
    lda #$00000001 ; Clear display
    jsr lcd_instruction
    ;;;;

    ; KEYBOARD INTERFACE SETUP
    lda #0
    sta IO_VIA2_DDRA ; All pins are input

    jsr monitor_loop

    .org $FFFA
    .word nmi
    .word reset
    .word irq