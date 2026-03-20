
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

ds1306_init:
    pha
    phx

    ldx #(DS1306_WRITE_MODIFIER | DS1306_CONTROL_REGISTER)
    lda #(DS1306_CTRL_BIT_1HZ)
    jsr ds1306_command

    plx
    pla
    rts

; Perform exchange with DS1306
; X: Address
; A: Data
ds1306_command:
    pha
    
    ; Enable device 2, clock chip
    lda #(SPI_DEVICE_2 | SPI_MODE_1)   
    jsr spi_set_device

    txa
    ; Send address
    jsr spi_transcieve
    
    pla
    ; Send / read byte
    jsr spi_transcieve

    pha
    ; Unset device
    lda #(SPI_DEVICES_DISABLED | SPI_MODE_1)
    jsr spi_set_device
    pla

    rts
