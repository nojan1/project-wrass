SPI_BUFFER = VAR_8BIT_1
SPI_BITMASK = VAR_8BIT_2

; Set the active SPI device to the line number in A
; A value of zero means no device is active
spi_set_device:
    and #$07
    asl
    asl
    asl
    asl
    sta IO_VIA1_PORTA
    rts

; Sends the byte stored in A over spi, toggling the clock
; Puts the return value into A
spi_transcieve:
brk_spi_transcieve:
    phx

    ldx #$0
    stx SPI_BUFFER

    ldx #$80 ; Used for the bit number
.bit_loop:
    stx SPI_BITMASK
    pha
    and SPI_BITMASK
    beq .send_zero

    ; Send one
    lda IO_VIA1_PORTA
    ora #$1 ; Mosi is pin 0

    jmp .clock

.send_zero:
    lda IO_VIA1_PORTA
    and #$FE

.clock:
    ; Toggle the SPI clock
    ora #$2 ; Set clock bit (pin 2)
    sta IO_VIA1_PORTA
    and #$FB ; Clear clock bit (pin 2)
    sta IO_VIA1_PORTA

    ; Recieve bit
    lda IO_VIA1_PORTA ; Miso is pin 1
    and #$1
    beq .got_zero

    ; Got a 1 
    lda SPI_BUFFER
    ora SPI_BITMASK
    sta SPI_BUFFER

.got_zero:
    lda SPI_BITMASK
    eor #$FF
    sta SPI_BITMASK

    lda SPI_BUFFER
    and #$FF
    sta SPI_BUFFER

    ; Prepare to process next bit
    txa
    lsr
    tax
    pla
    cpx #0
    bne .bit_loop

    lda SPI_BUFFER
    plx
    rts