; Read a block from the SD card (512 byte) using the block address stored in LBA_ADDRESS
; The data read will be put into SD_BUFFER
sd_read_block:
    sei
    pha
    phx
    phy

    lda #SD_CARD_SPI_DEVICE
    jsr spi_set_device

    lda #0
    sta ERROR

    ; Store destination to memory, set the high byte to one below since it is
    ; incremented below before the write starts
    sta PARAM_16_3
    lda #>SD_BUFFER - 1
    sta PARAM_16_3 + 1
    
    ; Send startbits and command index 17
    lda #%01010001
    jsr spi_transcieve

    ; Send parameters (32 bit), block address
    ldy #0

    lda LBA_ADDRESS, y
    jsr spi_transcieve   

    iny
    lda LBA_ADDRESS, y
    jsr spi_transcieve   
    
    iny
    lda LBA_ADDRESS, y
    jsr spi_transcieve   

    iny
    lda LBA_ADDRESS, y
    jsr spi_transcieve   

    ; Send CRC (ignored) and stop bit
    lda #$1
    jsr spi_transcieve

    jsr sd_wait_for_response 
    cmp #0
    bne .no_response

    ; Read the remaining 7 bits of R1
    ldx #$40
    jsr spi_read

    cmp #0
    bne .bad_token

    ; Read the supposed start data token
    lda #$FF
    jsr spi_transcieve

    cmp #$FE
    bne .bad_token

    ldx #3
.outer_loop:
    inc PARAM_16_3 + 1
    ldy #0
    dex
    beq .end_of_packet
.inner_loop:
    lda #$FF
    jsr spi_transcieve

    sta (PARAM_16_3), y

    iny
    beq .outer_loop
    jmp .inner_loop

.end_of_packet:
    ; Read CRC bytes
    lda #$FF
    jsr spi_transcieve

    lda #$FF
    jsr spi_transcieve

    jmp .done

.bad_token:
    lda #SD_READ_ERROR
    sta ERROR
    jmp .done

.no_response:
    lda #SD_READ_TIMEOUT
    sta ERROR

.done:
    ply
    plx
    pla
    cli
    rts