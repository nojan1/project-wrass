    .include "setup.s"

    jsr sys_newline

    ; Init VIA for SPI
    lda #0b11110101
    sta IO_SYSTEM_VIA_DDRA

    ldx #(DS1306_WRITE_MODIFIER | DS1306_CONTROL_REGISTER)
    lda #(DS1306_CTRL_BIT_1HZ)
    jsr ds1306_command

    ldx #(DS1306_YEAR)
    jsr ds1306_command
    jsr sys_puthex

    lda #'-'
    jsr sys_putc

    ldx #(DS1306_MONTH)
    jsr ds1306_command
    jsr sys_puthex

    lda #'-'
    jsr sys_putc

    ldx #(DS1306_DATE)
    jsr ds1306_command
    jsr sys_puthex

    lda #' '
    jsr sys_putc

    ldx #(DS1306_HOURS)
    jsr ds1306_command
    jsr sys_puthex

    lda #':'
    jsr sys_putc

    ldx #(DS1306_MINUTES)
    jsr ds1306_command
    jsr sys_puthex

    lda #':'
    jsr sys_putc

    ldx #(DS1306_SECONDS)
    jsr ds1306_command
    jsr sys_puthex
  
    jsr sys_newline

    rts ; Return to monitor

DS1306_WRITE_MODIFIER = $80
DS1306_SECONDS = $00
DS1306_MINUTES = $01
DS1306_HOURS = $02
DS1306_DAY = $03
DS1306_DATE = $04
DS1306_MONTH = $05
DS1306_YEAR = $06
 
DS1306_HOUR_12HOURS_BIT = 1 << 6
DS1306_HOUR_PM_BIT = 1 << 5

DS1306_CONTROL_REGISTER = $0F
DS1306_STATUS_REGISTER = $10
DS1306_TRICKLE_CHARGE_REGISTER = $11

DS1306_CTRL_BIT_WP = 1 << 6
DS1306_CTRL_BIT_1HZ = 1 << 2
DS1306_CTRL_BIT_AIE1 = 1 << 1
DS1306_CTRL_BIT_A1E0 = 1 << 0

DS1306_STATUS_BIT_IRQF1 = 1 << 1
DS1306_STATUS_BIT_IRQF0 = 1 << 0

DS1306_LOW_RAM = $20
DS1306_HIGH_RAM = $7f

; Perform exchange with DS1306
; X: Address
; A: Data
ds1306_command:
    pha
    
    ; Enable device 1, clock chip
    lda #(SPI_DEVICES_ENABLED | (1 << 1))    
    jsr spi_set_device

    txa
    ; Send address
    jsr spi_transcieve
    
    pla
    ; Send / read byte
    jsr spi_transcieve

    pha
    ; Unset device
    lda #SPI_DEVICES_DISABLED
    jsr spi_set_device
    pla

    rts

    .include "../kernel/include/io/spi.s"