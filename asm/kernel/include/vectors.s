irq:
    jmp (SYSTEM_IRQ)

default_system_irg:
    jsr scan_keyboard
    jmp (USER_IRQ)
no_user_irq:
    rti

nmi:
    jmp (SYSTEM_NMI)

default_system_nmi:
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

    lda #<default_system_irg
    sta SYSTEM_IRQ
    lda #>default_system_irg
    sta SYSTEM_IRQ + 1

    lda #<no_user_irq
    sta USER_IRQ
    lda #>no_user_irq
    sta USER_IRQ + 1

    lda #<default_system_nmi
    sta SYSTEM_NMI
    lda #>default_system_nmi
    sta SYSTEM_NMI + 1

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
    jsr spi_init

    lda #$FF
    jsr spi_transcieve

    jsr monitor_loop_start
