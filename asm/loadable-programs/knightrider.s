PHASE_COUNTER = ZP_USAGE_TOP + 1
DIRECTION = PHASE_COUNTER + 1

    .include "setup.s"
    sei

    lda #0
    sta PHASE_COUNTER
    sta DIRECTION

    lda #(GPU_OUTPUT | UART_OUTPUT | UART_INPUT_ENABLE)
    sta IO_CONTROL

    ; Set up timers
    lda #$FF
    sta IO_USER_VIA_T1CL
    sta IO_USER_VIA_T1CH ; Set timer 1 to $FFFF

    lda #%01000000 
    sta IO_USER_VIA_ACR ; timer 1 continues interupts

    lda #%11000000
    sta IO_USER_VIA_IER ; enable timer 1 interupts

    ; PortB all outputs
    lda #$FF
    sta IO_USER_VIA_DDRB

    lda #$1
    sta IO_USER_VIA_PORTB

    lda #<on_irq
    sta USER_IRQ

    lda #>on_irq
    sta USER_IRQ + 1

    cli
    rts

on_irq:
    pha
    lda IO_USER_VIA_T1CL ; Clear timer interupt    

    lda DIRECTION
    clc
    beq go_right
    ror IO_USER_VIA_PORTB
    jmp count

go_right:
    rol IO_USER_VIA_PORTB

count:
    lda PHASE_COUNTER
    clc
    adc #1
    cmp #7
    bne end

    lda DIRECTION
    eor #1
    sta DIRECTION

    lda #0
end:
    sta PHASE_COUNTER
    pla
    rti
