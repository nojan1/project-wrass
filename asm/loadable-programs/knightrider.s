    .include "setup.s"
    cli

    ; Set up timers
    lda #$FF 
    sta #IO_USER_VIA_T1LL
    sta #IO_USER_VIA_T1LH ; Set timer 1 latch to $FFFF

    lda #b01000000 
    sta #IO_USER_VIA_ACR ; timer 1 continues interupts

    lda #b11000000
    sta #IO_USER_VIA_IER ; enable timer 1 interupts

    ; PortB all outputs
    lda #$FF
    sta IO_USER_VIA_DDRB

    lda #$1
    sta IO_USER_VIA_PORTB

    sei
loop_left:
    jsr delay
    jsr delay
    jsr delay
    rol IO_USER_VIA_PORTB
    bcc loop_left

loop_right:
    jsr delay
    jsr delay
    jsr delay
    ror IO_USER_VIA_PORTB
    bcc loop_right

    jmp loop_left

delay:
    ldx #$ff
keep_waiting:
    .repeat 100
    nop
    .endr
    dex
    bne keep_waiting
    rts