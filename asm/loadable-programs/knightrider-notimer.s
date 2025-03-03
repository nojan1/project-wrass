    .include "setup.s"
    sei

    ; A, Accumilator
    ; X, Index
    ; Y

    ; PortB all outputs
    lda #$FF  ; Load A
    sta IO_USER_VIA_DDRB ; Store A

    lda #$1
    sta IO_USER_VIA_PORTB
    
loop_left:
    jsr delay
    jsr delay
    jsr delay
    rol IO_USER_VIA_PORTB
    bcc loop_left ; Branch if Carry clear

loop_right:
    jsr delay
    jsr delay
    jsr delay
    ror IO_USER_VIA_PORTB
    bcc loop_right

    jmp loop_left ; Unconditinoal jump

delay:
    ldx #$ff
keep_waiting:
    .repeat 100
    nop
    .endr
    dex
    bne keep_waiting
    rts