spi_init:
    ; All pins on PORTA of system VIA is output
    lda #$FF
    sta IO_SYSTEM_VIA_DDRA
    ; No SPI device selected, clocks low and all output selects inactive
    lda #0b11100000
    sta IO_SYSTEM_VIA_PORTA
    rts

; Set the active SPI device to the line number in A
; bit 0-2 are address
; bit 3 is CLOCK
; bit 4 is CLOCK_INVERT
; use by oring one of the SPI_DEVICE_X and SPI_MODE_X constants
spi_set_device:
    ora #$e0 ; make sure the top 3 bits are high (all chips charing PORTB is inactive)
    sta IO_SYSTEM_VIA_PORTA
    rts

; Sends the byte stored in A over spi, toggling the clock
; Puts the return value into A
spi_transcieve:
; brk spi_transc
    phx
    pha
    ; Set PORTB to output and write the value from A into it
    lda #$FF
    sta IO_SYSTEM_VIA_DDRB
    pla
    sta IO_SYSTEM_VIA_PORTB


    ; Then pulse the latch line for output shift register
    lda IO_SYSTEM_VIA_PORTA
    and #(~SPI_DATA_LATCHB)
    sta IO_SYSTEM_VIA_PORTA
    ora #SPI_DATA_LATCHB
    sta IO_SYSTEM_VIA_PORTA 

    ; Output shift register is now loaded.. we can begin clocking data by toggling the clock
    .repeat 16
    eor #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA
    .endr

    ; the recieve shift register now has the data... let's read it
    pha
    lda #$00
    sta IO_SYSTEM_VIA_DDRB

    pla
    and #(~SPI_OEB)
    sta IO_SYSTEM_VIA_PORTA
    pha

    lda IO_SYSTEM_VIA_PORTB
    tax

    pla
    ora #SPI_OEB
    sta IO_SYSTEM_VIA_PORTA

    txa

    ; temp debug code
    ;pha
    ;jsr sys_puthex
    ;lda #" "
    ;jsr sys_putc
    ;pla

    plx
    rts
