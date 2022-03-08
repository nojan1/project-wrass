    .org 0

    lda #$10

loop:
    sta $0
    ror
    jmp loop