    .include "setup.s"

    jsr sys_newline    

    jsr spi_init

    putstr_addr sdinit_string
    jsr sys_newline

    jsr sd_init
    jsr check_and_print_error
    jsr sys_newline

    lda ERROR
    bne return

    jsr mbr_thingy

return:
    rts ; Return to monitor

sdinit_string:
    .string "Executing SD init"
cmd17_string:
    .string "Running command 17 (reading block)"

mbr_thingy:
    lda #0
    sta LBA_ADDRESS + 0
    sta LBA_ADDRESS + 1
    sta LBA_ADDRESS + 2
    sta LBA_ADDRESS + 3

    jsr sd_read_block
    jsr check_and_print_error

    lda ERROR
    bne .mbr_thingy_done

    ; jsr print_sd_buffer

    jsr parse_mbr
    jsr check_and_print_error

    lda ERROR
    bne .mbr_thingy_done

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
    bne .mbr_thingy_done

    ; jsr print_sd_buffer

    jsr parse_fat_header
    jsr check_and_print_error

.mbr_thingy_done:
    rts

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


putc=sys_putc
newline=sys_newline
puthex=sys_puthex

    .include "../kernel/include/errors.s"
    .include "../kernel/include/utils/error_utils.s"
    .include "../kernel/include/io/spi.s"
    .include "../kernel/include/io/fs/partition.s"
    .include "../kernel/include/io/sd/init.s"
    .include "../kernel/include/io/sd/ops.s"