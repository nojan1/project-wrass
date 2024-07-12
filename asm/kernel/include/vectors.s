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
    sta IO_SYSTEM_VIA_DDRB ; All pins are input

    ; SPI INTERFACE SETUP
    lda #0b11110101
    sta IO_SYSTEM_VIA_DDRA

    jsr sd_dummy_boot_pulses
    jsr monitor_loop_start
