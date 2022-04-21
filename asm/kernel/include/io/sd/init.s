
; Send the 72 dummy pulses required to boot an SD-card
sd_dummy_boot_pulses:
    phx
    pha

    ; Make sure no device is selected
    lda #0
    jsr spi_set_device

    ldx #10
.send_pulse:
    lda #$FF
    jsr spi_transcieve

    dex
    bne .send_pulse

    pla
    plx
    rts

; Send CMD0 to SD-Card
sd_cmd0:
    sei
    pha

    lda #0
    sta ERROR

    lda #1 ; SPI device 1
    jsr spi_set_device

    ; Send startbits and command index 0
    lda #%01000000
    jsr spi_transcieve

    ; Send parameters (32 bit)
    .repeat 4
    lda #0
    jsr spi_transcieve   
    .endrep

    ; Send CRC and stop bit
    lda #%10010101
    jsr spi_transcieve

    ; Wait for the SD-card to start returning a response
    jsr sd_wait_for_response 
    cmp #0
    bne .no_response

    ; Read the remaining 7 bits
    ldx #$40
    jsr spi_read

    jsr puthex
    jsr newline

    cmp #1 ; Only the "In idle state" flag should be set
    beq .done

.no_response:
    lda #SD_CARD_INIT_FAILED
    sta ERROR

.done:
    pla
    cli
    rts

; Send CMD16 (block set) to SD-Card, this will set the block size to 512 bytes
sd_cmd16:
    sei
    pha

    lda #0
    sta ERROR

    lda #1 ; SPI device 1
    jsr spi_set_device

    ; Send startbits and command index 16
    lda #%01010000
    jsr spi_transcieve

    ; Send parameters (32 bit), for blocksize of 512
    .repeat 2
    lda #0
    jsr spi_transcieve   
    .endrep

    lda #2
    jsr spi_transcieve   

    lda #0
    jsr spi_transcieve   

    ; Send CRC (ignored) and stop bit
    lda #$1
    jsr spi_transcieve

    ; Wait for the SD-card to start returning a response
    jsr sd_wait_for_response 
    cmp #0
    bne .no_response

    ; Read the remaining 7 bits
    ldx #$40
    jsr spi_read

    jsr puthex
    jsr newline

    cmp #0 ; Only the "In idle state" flag should be set
    beq .done

.no_response:
    lda #SD_CARD_BLOCKSET_FAILED
    sta ERROR

.done:
    pla
    cli
    rts

; Toggles the SPI clock and waits for Miso to go low
; This expects the SD card to be the selected device
; If a response is recieved before timeout A will be zero
; Mutates: A, X
sd_wait_for_response:
    ldx #16

.keep_waiting:
    dex
    beq .return

    lda IO_VIA1_PORTA
    jsr spi_clk
    bne .keep_waiting

.return:
    rts