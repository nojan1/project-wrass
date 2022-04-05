    .macro putstr_addr, ptr
    lda #<\ptr
    sta PARAM_16_1
    lda #>\ptr
    sta PARAM_16_1 + 1
    jsr putstr
    .endmacro