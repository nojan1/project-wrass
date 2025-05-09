initsd_command_implementation:
    nop

    jsr sd_init
    jsr check_and_print_error

    lda ERROR
    bne _initsd_done

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

    lda ERROR
    bne _initsd_done

    jsr parse_mbr
    jsr check_and_print_error

    lda ERROR
    bne _initsd_done

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

    lda ERROR
    bne _initsd_done

    jsr parse_fat_header
    jsr check_and_print_error
    
_initsd_done:
    jmp _command_execution_complete