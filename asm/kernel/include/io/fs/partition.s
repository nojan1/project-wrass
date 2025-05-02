;;;;;; CHEAT.. note this is for FAT32 only.. FAT16 stores the root directrory differently
;
; (unsigned long)fat_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors;
; (unsigned long)cluster_begin_lba = Partition_LBA_Begin + Number_of_Reserved_Sectors + (Number_of_FATs * Sectors_Per_FAT);
; (unsigned char)sectors_per_cluster = BPB_SecPerClus;
; (unsigned long)root_dir_first_cluster = BPB_RootClus;
;;;;


partition_type_string:
    .string "Partition type: "

partition_start_string:
    .string "Partition 1 start (LBA): "

; Scan the sector stored in SD_BUFFER assuming it is an MBR block
; Check that the partition type of the first partition is supported
; Then store the LBA address to that partition in PARTITION_LBA
parse_mbr:
    sei
    pha

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

cluster_begin_lba_string:
    .string "Cluster begin: "

fat_begin_lba_string:
    .string "FAT begin: "

; Read the FAT32 header and parse information about the filesystem
; Assumes SD_BUFFER contains the first 512 bytes of the filesystem
parse_fat_header:
    pha
    phy
    sei

    ; Assuming we just read the file system root.. LBA_ADDRESS should point to the start of said filesystem
    ; But in the wrong order
    lda LBA_ADDRESS + 0
    sta FAT_BEGIN_LBA + 3
    lda LBA_ADDRESS + 1
    sta FAT_BEGIN_LBA + 2
    lda LBA_ADDRESS + 2
    sta FAT_BEGIN_LBA + 1
    lda LBA_ADDRESS + 3
    sta FAT_BEGIN_LBA + 0
    ; FAT_BEGIN_LBA is the start of file system plus the reserved sectors

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
    sta SECTORS_PER_CLUSTER
    jsr puthex
    jsr newline

    putstr_addr reserved_sectors_string
    lda SD_BUFFER + 0x0E + 1
    jsr puthex

    ; Add high 8 bit of the 16 bit word to the second byte of FAT_BEGIN_LBA
    clc
    adc FAT_BEGIN_LBA + 1
    sta FAT_BEGIN_LBA + 1

    lda SD_BUFFER + 0x0E
    jsr puthex

    ; ...and the low 8 bit of the 16 bit word to the first byte of FAT_BEGIN_LBA
    clc
    adc FAT_BEGIN_LBA + 0
    sta FAT_BEGIN_LBA + 0
    ; Yes we assume that we will never get an overflow to byte 3.... or between byte 1 and 2 for that matter
    ; // Super safe code

    jsr newline

    putstr_addr fat_begin_lba_string
    lda FAT_BEGIN_LBA + 3
    jsr puthex
    lda FAT_BEGIN_LBA + 2
    jsr puthex
    lda FAT_BEGIN_LBA + 1
    jsr puthex
    lda FAT_BEGIN_LBA + 0
    jsr puthex

    jsr newline

    ; FAT_BEGIN_LBA also serves as the base for CLUSTER_BEGIN_LBA
    lda FAT_BEGIN_LBA + 0
    sta CLUSTER_BEGIN_LBA + 0
    lda FAT_BEGIN_LBA + 1
    sta CLUSTER_BEGIN_LBA + 1
    stz CLUSTER_BEGIN_LBA + 2
    stz CLUSTER_BEGIN_LBA + 3

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
    sta TERM_32_1_4
    jsr puthex
    lda SD_BUFFER + 0x24 + 2
    sta TERM_32_1_3
    jsr puthex
    lda SD_BUFFER + 0x24 + 1
    sta TERM_32_1_2
    jsr puthex
    lda SD_BUFFER + 0x24
    sta TERM_32_1_1
    jsr puthex

    jsr newline

    ; If we got here there where 2 FATs, that means we can just shift TERM_32_1_X left to perform (Number_of_FATs * Sectors_Per_FAT)
    clc
    rol TERM_32_1_1
    rol TERM_32_1_2
    rol TERM_32_1_3
    rol TERM_32_1_4

    ; No we can add it with CLUSTER_BEGIN_LBA to get the actual start of the cluster
    clc
    lda TERM_32_1_1
    adc CLUSTER_BEGIN_LBA + 0
    sta CLUSTER_BEGIN_LBA + 0

    lda TERM_32_1_2
    adc CLUSTER_BEGIN_LBA + 1
    sta CLUSTER_BEGIN_LBA + 1

    lda TERM_32_1_3
    adc CLUSTER_BEGIN_LBA + 2
    sta CLUSTER_BEGIN_LBA + 2

    lda TERM_32_1_4
    adc CLUSTER_BEGIN_LBA + 3
    sta CLUSTER_BEGIN_LBA + 3

    ; Print it for fun
    putstr_addr cluster_begin_lba_string
    lda CLUSTER_BEGIN_LBA + 3
    jsr puthex
    lda CLUSTER_BEGIN_LBA + 2
    jsr puthex
    lda CLUSTER_BEGIN_LBA + 1
    jsr puthex
    lda CLUSTER_BEGIN_LBA + 0
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
    sta ROOT_CLUSTER ; We cheat a bit and assume that is always less then 256 (probably 2 in 99% of the cases)
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
