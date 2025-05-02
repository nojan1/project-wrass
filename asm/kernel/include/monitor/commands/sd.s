sd_command_implementation:
    nop

    jsr sd_init
    jsr check_and_print_error

    ; jsr sd_cmd16
    ; jsr check_and_print_error

    ; Set the block address
    lda #0
    sta LBA_ADDRESS + 0
    sta LBA_ADDRESS + 1
    sta LBA_ADDRESS + 2
    sta LBA_ADDRESS + 3

    jsr sd_read_block
    jsr check_and_print_error

    jsr parse_mbr
    jsr check_and_print_error

    lda PARTITION_LBA + 0
    sta LBA_ADDRESS + 3
    lda PARTITION_LBA + 1
    sta LBA_ADDRESS + 2
    lda PARTITION_LBA + 2
    sta LBA_ADDRESS + 1
    lda PARTITION_LBA + 3
    sta LBA_ADDRESS + 0

    jsr sd_read_block
    jsr check_and_print_error

    jsr parse_fat_header
    jsr check_and_print_error

    jsr list_root_directory
    ; jsr print_sd_buffer

    jmp _command_execution_complete

print_sd_buffer:
    pha
    phy
    ldy #0

.print_next_1:
    lda SD_BUFFER,y
    jsr sys_puthex

    lda #" "
    jsr sys_putc

    tya
    and #$F
    cmp #$F
    bne .no_newline_1
    jsr sys_newline

.no_newline_1:
    iny
    bne .print_next_1

    ldy #0

.print_next_2:
    lda SD_BUFFER + 256,y
    jsr sys_puthex

    lda #" "
    jsr sys_putc

    tya
    and #$F
    cmp #$F
    bne .no_newline_2
    jsr sys_newline

.no_newline_2:
    iny
    bne .print_next_2

    ply
    pla
    rts