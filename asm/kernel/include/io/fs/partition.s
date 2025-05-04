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

ATTR_READ_ONLY = 0x01
ATTR_HIDDEN = 0x02
ATTR_SYSTEM = 0x04
ATTR_VOLUME_ID = 0x08
ATTR_DIRECTORY = 0x10
ATTR_ARCHIVE = 0x20
ATTR_LONG_NAME = ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID

list_directory_header:
    .string "EXT  NAME      SIZE       CLUSTER"

directory_text:
    .string "DIR"

; Lists the root directory of the FAT32 filesystem
; This assumes that parse_fat_headers have run and setup the required variables
list_root_directory: 
    lda ROOT_CLUSTER
    sta CURRENT_CLUSTER + 0
    stz CURRENT_CLUSTER + 1 
    stz CURRENT_CLUSTER + 2
    stz CURRENT_CLUSTER + 3

; Lists the directory located at cluster specified by CURRENT_CLUSTER in the FAT32 filesystem
; This assumes that parse_fat_headers have run and setup the required variables
list_directory:
    putstr_addr list_directory_header
    jsr newline

_list_directory_read_cluster:
    ldx #0
_list_directory_read_next_sector:
    phx

    stz ERROR
    jsr read_cluster 

    ; Check that the cluster was read correctly
    lda ERROR
    beq _list_directory_cluster_read
    rts
_list_directory_cluster_read:

    ; Each entry is 32 bit, create a pointer pointing at the start.
    ; We will then keep adding 32 until it overflow or we find the end of directory marker?
    lda #<SD_BUFFER
    sta TERM_16_1_LOW
    lda #>SD_BUFFER
    sta TERM_16_1_HIGH

    ldx #512/32
_list_directory_next_entry:
    ; Load the first character of the name to check for deleted or free
    ldy #0
    lda (TERM_16_1_LOW), y
    beq _list_directory_setup_next_entry ; It was 0 == Free

    cmp #$E5
    beq _list_directory_setup_next_entry ; It 0xE5 == Deleted

    ; First lets load the attribute byte
    ldy #$0B

    lda (TERM_16_1_LOW), y

    and #ATTR_SYSTEM | ATTR_HIDDEN | ATTR_VOLUME_ID
    bne _list_directory_setup_next_entry

    ; This file should be displayed.. start displaying the info
    jsr print_entry

_list_directory_setup_next_entry:
    lda #32
    clc
    adc TERM_16_1_LOW
    sta TERM_16_1_LOW
    lda #0
    adc TERM_16_1_HIGH
    sta TERM_16_1_HIGH

    dex
    bne _list_directory_next_entry

    plx
    inx
    cpx SECTORS_PER_CLUSTER
    bne _list_directory_read_next_sector

    jsr try_advance_to_next_cluster
    bcs _list_directory_read_cluster

    rts

; Print the current directory entry pointed to by TERM_16_1_LOW
print_entry:
    lda (TERM_16_1_LOW), y
    and #ATTR_DIRECTORY
    beq _print_entry_print_ext
    putstr_addr directory_text
    bra _print_entry_print_name

_print_entry_print_ext:
    ldy #8
_print_entry_print_next_character_ext:
    lda (TERM_16_1_LOW), y
    jsr putc

    iny
    cpy #11
    bne _print_entry_print_next_character_ext

_print_entry_print_name:
    lda #" "
    jsr putc
    jsr putc

    ldy #0
_print_entry_print_next_character:
    lda (TERM_16_1_LOW), y
    jsr putc

    iny
    cpy #8
    bne _print_entry_print_next_character

    lda #" "
    jsr putc
    jsr putc

    ; Print the file size
    ldy #$1C + 3
    lda (TERM_16_1_LOW), y
    jsr puthex
    ldy #$1C + 2
    lda (TERM_16_1_LOW), y
    jsr puthex
    ldy #$1C + 1
    lda (TERM_16_1_LOW), y
    jsr puthex    
    ldy #$1C + 0
    lda (TERM_16_1_LOW), y
    jsr puthex


    lda #" "
    jsr putc
    jsr putc

    ; Print cluster address
    ; Upper
    ldy #$14 + 1
    lda (TERM_16_1_LOW), y
    jsr puthex
    ldy #$14 + 0
    lda (TERM_16_1_LOW), y
    jsr puthex

    ; Lower
    ldy #$1A + 1
    lda (TERM_16_1_LOW), y
    jsr puthex
    ldy #$1A + 0
    lda (TERM_16_1_LOW), y
    jsr puthex

    jsr newline

    rts

; Reads cluster from SD card
; Expected cluster number (32 bit) in CURRENT_CLUSTER
; The value in X will be used as an offset to read a different sector within the cluster
; Mutates A and X
read_cluster:
    ; We need to perform (CLUSTER_NUM - 2) * SECTORS_PER_CLUSTER
    phx

    sec
    lda #2
    sbc CURRENT_CLUSTER + 0
    sta TERM_32_1_1

    lda #0
    sbc CURRENT_CLUSTER + 1
    sta TERM_32_1_2

    lda #0
    sbc CURRENT_CLUSTER + 2
    sta TERM_32_1_3

    lda #0
    sbc CURRENT_CLUSTER + 3
    sta TERM_32_1_4

    ; That did the -2 part.. now for the multiplication
    ldx SECTORS_PER_CLUSTER
_read_cluster_keep_shifting:
    clc
    rol TERM_32_1_1
    rol TERM_32_1_2
    rol TERM_32_1_3
    rol TERM_32_1_4

    txa
    lsr
    tax

    bne _read_cluster_keep_shifting

    ; Add the offset in X (currently on stack) to the lower byte... and make sure the carry ripples through
    clc
    pla
    adc TERM_32_1_1
    sta TERM_32_1_1
    lda #0
    adc TERM_32_1_2
    sta TERM_32_1_2
    lda #0
    adc TERM_32_1_3
    sta TERM_32_1_3
    lda #0
    adc TERM_32_1_4
    sta TERM_32_1_4

    ; Add the start of the cluster and setup LBA_ADDRESS
    clc
    lda CLUSTER_BEGIN_LBA + 0
    adc TERM_32_1_1
    sta LBA_ADDRESS + 3
    lda CLUSTER_BEGIN_LBA + 1
    adc TERM_32_1_2
    sta LBA_ADDRESS + 2
    lda CLUSTER_BEGIN_LBA + 2
    adc TERM_32_1_3
    sta LBA_ADDRESS + 1
    lda CLUSTER_BEGIN_LBA + 3
    adc TERM_32_1_4
    sta LBA_ADDRESS + 0

    ; Hand over execution to sd_read_block
    jmp sd_read_block

; Lookup the current CURRENT_CLUSTER in the FAT and advance to the next one
; Will set carry flag if already on end of chain
try_advance_to_next_cluster:
    pha
    phy

    ; First we need to find the correct FAT and load it, this is the 512 block within the fat which contains the index for this cluster
    ; each index takes up 4 bytes (32 bit), giving the expression FAT_BEGIN_LBA + int(CURRENT_CLUSTER / 128)
    ; We start by putting CURRENT_CLUSTER into the working area
    lda CURRENT_CLUSTER + 0
    sta TERM_32_1_1
    lda CURRENT_CLUSTER + 1
    sta TERM_32_1_2
    lda CURRENT_CLUSTER + 2
    sta TERM_32_1_3
    lda CURRENT_CLUSTER + 3
    sta TERM_32_1_4

    ; now divide by 128 == shift left 7 times
    .repeat 7
    clc
    rol TERM_32_1_1
    rol TERM_32_1_2
    rol TERM_32_1_3
    rol TERM_32_1_4
    .endrepeat

    ; Now we need to add FAT_BEGIN_LBA
    clc
    lda TERM_32_1_1
    adc FAT_BEGIN_LBA + 0
    sta LBA_ADDRESS + 3
    lda TERM_32_1_2
    adc FAT_BEGIN_LBA + 1
    sta LBA_ADDRESS + 2
    lda TERM_32_1_3
    adc FAT_BEGIN_LBA + 2
    sta LBA_ADDRESS + 1
    lda TERM_32_1_4
    adc FAT_BEGIN_LBA + 3
    sta LBA_ADDRESS + 0

    ; Now we can load the sector
    jsr sd_read_block
    lda ERROR
    bne _try_advance_to_next_cluster_done

    ; To continue we need to calculate the offset into the sector currently stored in SD_BUFFER
    ; expression is: (CURRENT_CLUSTER & 0x7F*) * 4
    lda CURRENT_CLUSTER + 0
    and #$7F ; blank out everything but the bottom 128
    sta TERM_32_1_1
    stz TERM_32_1_2
    stz TERM_32_1_3
    stz TERM_32_1_4

    ; Shift left 2 times (we can drop to 16 bit here)
    .repeat 2
    clc
    rol TERM_32_1_1
    rol TERM_32_1_2
    .endrepeat

    ; Now add the offset of SD_BUFFER since that is where the data is in memory
    ; Use byte 3 and 4 to handle endianess swap
    clc
    lda #>SD_BUFFER
    adc TERM_32_1_1
    sta TERM_32_1_4
    lda #<SD_BUFFER
    adc TERM_32_1_2
    sta TERM_32_1_3

    ; Start reading the entry for the cluster and check for end of chain marker
    ; 0xFFFFFFF8 - 0xFFFFFFFF
    ldy #0
    lda (TERM_32_1_3), y
    cmp #$FF
    bne _not_end_of_chain
    ; top bit is $FF

    iny
    lda (TERM_32_1_3), y
    cmp #$FF
    bne _not_end_of_chain
    ; next bit is also $FF

    iny
    lda (TERM_32_1_3), y
    cmp #$FF
    bne _not_end_of_chain
    ; next bit is also $FF

    iny
    lda (TERM_32_1_3), y
    and #$F
    cmp #$F
    bne _not_end_of_chain

    ; Oops this is an end of chain
    sec
    bra _try_advance_to_next_cluster_done

_not_end_of_chain:
    ; Set CURRENT_CLUSTER and return
    ldy #0
    lda (TERM_32_1_3), y
    sta CURRENT_CLUSTER + 0
    iny
    lda (TERM_32_1_3), y
    sta CURRENT_CLUSTER + 1
    iny
    lda (TERM_32_1_3), y
    sta CURRENT_CLUSTER + 2
    iny
    lda (TERM_32_1_3), y
    and #$F
    sta CURRENT_CLUSTER + 3

    clc

_try_advance_to_next_cluster_done:
    ply
    pla
    rts