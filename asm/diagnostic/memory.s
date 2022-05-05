; Tests blocks of memory with different values. Uses variables
; MEM_LOW: Automatically set to 0
; MEM_HIGH: Set this to one less then the start block
; MEM_UPPER_BOUNDRY: Set this to High value that indicates end

test_mem:
.next_high:
    lda #0
    sta MEM_LOW
    inc MEM_HIGH

    lda MEM_HIGH
    cmp MEM_UPPER_BOUNDRY
    beq .success
.test_next:
    test_byte MEM_LOW, .mem_loop_write_fail
    inc MEM_LOW
    bne .test_next
    jmp .next_high

.mem_loop_write_fail:
    dec MEM_LOW
    lda #RAM_LOOP_WRITE_FAIL
    jmp .done

.success:
    lda #0

.done:
    rts

test_rom:
    ldy #0
    lda #$C0
    sta MEM_HIGH
    lda #$0
    sta MEM_LOW
.test_next_1: 
    lda (MEM_LOW), y
    cmp MEM_LOW
    bne .rom1_first_data__fail
    inc MEM_LOW
    cmp #5
    bne .test_next_1

    ldy #0
    lda #$D0
    sta MEM_HIGH
    lda #$0
    sta MEM_LOW
.test_next_2: 
    lda (MEM_LOW), y
    cmp MEM_LOW
    bne .rom1_second_data__fail
    inc MEM_LOW
    cmp #5
    bne .test_next_2
    jmp .success

.rom1_first_data__fail:
    lda #ROM_1_FIRST_DATA_FAIL
    jmp .done

.rom1_second_data__fail:
    lda #ROM_1_SECOND_DATA_FAIL
    jmp .done

.success:
    lda #0

.done:
    rts