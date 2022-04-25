partition_type_string:
    .string "Partition type: "

partition_start_string:
    .string "Start: "

; Scan the sector stored in SD_BUFFER assuming it is an MBR block
; Check that the partition type of the first partition is supported
; Then store the LBA address to that partition in PARTITION_LBA
parse_mbr:
    sei
    pha

; brk_asd:
    lda SD_BUFFER + 511
    cmp #$AA
    bne .invalid_mbr

    lda SD_BUFFER + 510
    cmp #$55
    bne .invalid_mbr

    putstr_addr partition_type_string

    ; Partition type
    lda SD_BUFFER + 0x01BE + 0x04
    beq .bad_partition_type

    jsr puthex
    jsr newline

    putstr_addr partition_start_string

    ; Start address
    lda SD_BUFFER + 0x01BE + 0x08 + 3
    sta PARTITION_LBA + 3
    jsr puthex

    lda SD_BUFFER + 0x01BE + 0x08 + 2
    sta PARTITION_LBA + 2
    jsr puthex
    
    lda SD_BUFFER + 0x01BE + 0x08 + 1
    sta PARTITION_LBA + 1
    jsr puthex

    lda SD_BUFFER + 0x01BE + 0x08 + 0
    sta PARTITION_LBA + 0
    jsr puthex
    

    jsr newline

    jmp .done

.invalid_mbr:
    lda #INVALID_MBR
    sta ERROR
    jmp .done

.bad_partition_type:
    lda #NO_VALID_PARTITION
    sta ERROR

.done:  
    pla
    cli
    rts