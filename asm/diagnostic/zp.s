
test_zp:
    lda #$55
    sta $01

    lda #0
    lda $01
    cmp #$55
    bne .zp_first_write_broken

    ; Okey, seems that the zero page should be working. Lets test all of it
    lda #$0
    sta $2

    lda #3
    sta $1
.test_next:
    test_byte $1, .zp_loop_write_fail
    inc $1
    bne .test_next
    jmp .success

.zp_loop_write_fail:
    lda #ZP_LOOP_WRITE_FAIL
    jmp .done

.zp_first_write_broken:
    lda #ZP_FIRST_WRITE_FAIL
    jmp .done

.success:
    lda #0

.done:
    rts