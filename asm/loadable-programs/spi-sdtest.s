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

    ; lda #((0 << 4) | 2)
    ; sta SPI_CONFIG
    ; jsr spi_clock_inactive

    ; jsr sd_dummy_boot_pulses

    ; putstr_addr cmd0_string
    ; jsr newline

    ; jsr sd_cmd0
    ; jsr sys_puthex
    ; jsr sys_newline
    ; jsr check_and_print_error

    ; putstr_addr cmd8_string
    ; jsr newline
    
    ; jsr sd_cmd8    
    ; jsr newline
    ; jsr print_sd_buffer
    ; jsr newline
    ; jsr check_and_print_error

    ; putstr_addr cmd58_string
    ; jsr newline
    
    ; jsr sd_cmd58    
    ; jsr newline
    ; jsr print_sd_buffer
    ; jsr newline
    ; jsr check_and_print_error

    ; putstr_addr acmd41_string
    ; jsr newline
    ; jsr check_and_print_error

    ; putstr_addr cmd58_string
    ; jsr newline
    
    ; jsr sd_cmd58    
    ; jsr check_and_print_error
    ; jsr sys_newline

    putstr_addr cmd17_string
    jsr newline

    lda #0
    sta LBA_ADDRESS + 0
    sta LBA_ADDRESS + 1
    sta LBA_ADDRESS + 2
    sta LBA_ADDRESS + 3

    jsr sd_read_block
    jsr newline
    jsr check_and_print_error

    ldy #0
    ldx #16
.next_byte:
    lda SD_BUFFER, y
    jsr sys_puthex
    lda #" "
    jsr sys_putc

    iny
    beq return

    dex
    bne .next_byte

    jsr sys_newline
    ldx #16
    bra .next_byte


return:
    rts ; Return to monitor

sdinit_string:
    .string "Executing SD init"
cmd0_string:
    .string "Running command 0"
cmd8_string:
    .string "Running command 8"
cmd58_string:
    .string "Running command 58"
acmd41_string:
    .string "Running command A41"
cmd17_string:
    .string "Running command 17 (reading block)"

print_sd_buffer:
    pha
    ldy #0

.print_next:
    lda SD_BUFFER,y
    jsr sys_puthex

    lda #" "
    jsr sys_putc

    iny
    cpy #5
    bne .print_next

    pla
    rts


putc=sys_putc
newline=sys_newline
puthex=sys_puthex

    .include "../kernel/include/errors.s"
    .include "../kernel/include/utils/error_utils.s"
    .include "../kernel/include/io/spi.s"
    ; .include "../kernel/include/io/fs/partition.s"
    .include "../kernel/include/io/sd/init.s"
    .include "../kernel/include/io/sd/ops.s"