
test_lowmem:
    lda #$01
    sta $2

.next_high:
    lda #0
    sta $1
    inc $2

    lda $2
    cmp #$80
    beq .success
.test_next:
    test_byte $1, .mem_loop_write_fail
    inc $1
    bne .test_next
    jmp .next_high

.mem_loop_write_fail:
    lda #ZP_LOOP_WRITE_FAIL
    jmp .done

.success:
    lda #0

.done:
    rts