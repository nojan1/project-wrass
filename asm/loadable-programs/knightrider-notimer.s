    .include "setup.s"
    sei

    ; PortB all outputs
    lda #$FF
    sta IO_USER_VIA_DDRB

    lda #$1
    sta IO_USER_VIA_PORTB
    
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