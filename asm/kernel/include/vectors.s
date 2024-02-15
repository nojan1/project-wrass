irq:
    jsr scan_keyboard
    rti

nmi:
    nop
    rti

reset:
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER
    sta KEYBOARD_FLAGS
    sta CURRENT_LINE
    sta CURRENT_COLUMN

    .ifndef NO_GPU
    jsr gpu_display_init
    .endif
    
    .ifndef NO_LCD
    jsr lcd_display_init
    .endif

    ; lda #(KEYBOARD_INPUT | GPU_OUTPUT)
    lda #(KEYBOARD_INPUT | GPU_OUTPUT | UART_OUTPUT | UART_INPUT_ENABLE)
    sta IO_CONTROL

    ; KEYBOARD INTERFACE SETUP
    lda #0
    sta IO_VIA2_DDRA ; All pins are input

    ; SPI INTERFACE SETUP
    lda #0b01110101
    sta IO_VIA1_DDRA

    jsr sd_dummy_boot_pulses


    ; lda #0
    ; sta TERM_16_1_HIGH
    ; lda #64
    ; sta TERM_16_1_LOW

    ; lda #0
    ; sta TERM_16_2_HIGH
    ; lda #2
    ; sta TERM_16_2_LOW

    ; jsr mul_16 

    ; lda #10
    ; sta TERM_16_2_LOW

    ; jsr add_16

    ; lda TERM_16_1_HIGH
    ; jsr puthex 
    ; lda TERM_16_1_LOW
    ; jsr puthex
    
    ; ; Temp 
    ; jsr init_sd
    
    ; ; Wait here forever... and ever .... and ever
    ; jmp *

    jsr monitor_loop_start

init_sd:
    jsr sd_cmd0
    jsr check_and_print_error

    jsr sd_cmd16
    jsr check_and_print_error

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

    rts
