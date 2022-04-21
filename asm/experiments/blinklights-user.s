CONTROL=$0

    .org $04C0
    
    lda #0b00010000
loop:
    sta CONTROL
    clc
    rol a ; Rotate result left
    bne dont_reset
    lda #0b00010000 ; Set firs bit to 1

dont_reset:
    jsr wait
    jsr wait
    jsr wait
    jsr wait
    jsr wait
    jsr wait
    jmp loop

wait:
    ldy #0
_wait_loop:
    iny
    nop
    cpy #255
    bne _wait_loop
    rts