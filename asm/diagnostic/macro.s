    .macro test_byte, target, errorlabel
    ldy #0
    lda #0  
    sta (\target),y
    lda (\target),y
    cmp #0
    bne \errorlabel
    lda #$FF  
    sta (\target),y
    lda (\target),y
    cmp #$FF
    bne \errorlabel
    lda #$AA 
    sta (\target),y
    lda (\target),y
    cmp #$AA
    bne \errorlabel
    .endmacro
 
    .macro putstr_addr, ptr
    lda #<\ptr
    sta PARAM_16_1
    lda #>\ptr
    sta PARAM_16_1 + 1
    jsr putstr
    .endmacro