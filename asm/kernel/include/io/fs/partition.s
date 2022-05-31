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

bytes_per_sector_string:
    .string "Bytes per sector: "

sectors_per_cluster_string:
    .string "Sectors per cluster: "

reserved_sectors_string:
    .string "Reserved sectors: "

number_of_fats_string:
    .string "Number of fats: "

root_entries_string:
    .string "Root entries: "

sectors_per_fat_string:
    .string "Sectors per fat: "

large_sectors_string:
    .string "Large sectors: "

root_cluster_number_string:
    .string "Root cluster number: "

volume_label_string:
    .string "Volume label: "

; Read the FAT32 header and parse information about the filesystem
; Assumes SD_BUFFER contains the first 512 bytes of the filesystem
parse_fat_header:
    pha
    phy
    sei

    lda #0
    sta ERROR

    putstr_addr bytes_per_sector_string
    lda SD_BUFFER + 0x0B + 1
    jsr puthex
    lda SD_BUFFER + 0x0B
    jsr puthex

    jsr newline

    putstr_addr sectors_per_cluster_string
    lda SD_BUFFER + 0x0D
    jsr puthex
    jsr newline

    putstr_addr reserved_sectors_string
    lda SD_BUFFER + 0x0E + 1
    jsr puthex
    lda SD_BUFFER + 0x0E
    jsr puthex

    jsr newline

    putstr_addr number_of_fats_string
    lda SD_BUFFER + 0x10
    cmp #2
    beq .correct_number_of_fats
    jmp .bad_number_of_fats

.correct_number_of_fats:
    jsr puthex

    jsr newline

    putstr_addr root_entries_string
    lda SD_BUFFER + 0x11 + 1
    jsr puthex
    lda SD_BUFFER + 0x11
    jsr puthex

    jsr newline

    putstr_addr sectors_per_fat_string
    lda SD_BUFFER + 0x24 + 3
    jsr puthex
    lda SD_BUFFER + 0x24 + 2
    jsr puthex
    lda SD_BUFFER + 0x24 + 1
    jsr puthex
    lda SD_BUFFER + 0x24
    jsr puthex

    jsr newline

    putstr_addr large_sectors_string
    lda SD_BUFFER + 0x20 + 3
    jsr puthex
    lda SD_BUFFER + 0x20 + 2
    jsr puthex
    lda SD_BUFFER + 0x20 + 1
    jsr puthex
    lda SD_BUFFER + 0x20
    jsr puthex

    jsr newline

    putstr_addr root_cluster_number_string
    lda SD_BUFFER + 0x2c + 3
    jsr puthex
    lda SD_BUFFER + 0x2c + 2
    jsr puthex
    lda SD_BUFFER + 0x2c + 1
    jsr puthex
    lda SD_BUFFER + 0x2c
    jsr puthex

    jsr newline

    putstr_addr volume_label_string

    ldy #$47
.next_character:
    lda SD_BUFFER, y
    jsr putc
    iny
    cpy #$47 + 11
    bne .next_character

    jsr newline

    lda SD_BUFFER + 0x52 + 0
    cmp #"F"
    bne .bad_partion

    lda SD_BUFFER + 0x52 + 1
    cmp #"A"
    bne .bad_partion

    lda SD_BUFFER + 0x52 + 2
    cmp #"T"
    bne .bad_partion

    lda SD_BUFFER + 0x52 + 3
    cmp #"3"
    bne .bad_partion

    lda SD_BUFFER + 0x52 + 4
    cmp #"2"
    bne .bad_partion



    jmp .done

.bad_number_of_fats:
    lda #UNSUPPORTED_NUMBER_OF_FATS
    sta ERROR
    jmp .done

.bad_partion:
    lda #NO_VALID_PARTITION
    sta ERROR

.done:
    cli
    pla
    ply
    rts
