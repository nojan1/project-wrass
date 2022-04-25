; Read a block from the SD card using the block address stored in A, X and Y on the format
; 0 X Y A
; The data read will be put into SD_BUFFER
; Mutates: A, X, Y
sd_read_block:
    sei
    
    pha
    lda #SD_CARD_SPI_DEVICE
    jsr spi_set_device

    lda #0
    sta ERROR

    ; Send startbits and command index 17
    lda #%01010001
    jsr spi_transcieve

    ; Send parameters (32 bit), block address
    lda #0
    jsr spi_transcieve   

    txa
    jsr spi_transcieve   
    
    tya
    jsr spi_transcieve   

    pla
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

    jsr puthex
    jsr newline

    cmp #0
    bne .bad_token

    ; Read the supposed start data token
    lda #$FF
    jsr spi_transcieve

    jsr puthex
    jsr newline

    cmp #$FE
    bne .bad_token

    ldx #3
.outer_loop:
    ldy #255
    dex
    beq .end_of_packet
.inner_loop:
    lda #$FF
    jsr spi_transcieve

    ; Store the byte here...
    jsr puthex
    lda " "
    jsr putc

    dey
    beq .outer_loop
    jmp .inner_loop

.end_of_packet:
    ; Read the last 2 bytes up to 512... TODO: Revisit this
    .repeat 2
    lda #$FF
    jsr spi_transcieve

    ; Store the byte here...
    jsr puthex
    lda " "
    jsr putc
    .endrepeat

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
    cli
    rts