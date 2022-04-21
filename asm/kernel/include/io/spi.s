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
; brk_spi_transcieve:
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
    jsr spi_clk
    beq .got_zero

    ; Got a 1 
    lda SPI_BUFFER
    ora SPI_BITMASK
    sta SPI_BUFFER

.got_zero:
    ; Invert the bitmask
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

; Read up to 8 bits from SPI and store in A. The clock will be toggled and Mosi will be 1
; The offset in X will be used to determing bit position. 
; To read a full byte set it to $80 before calling
spi_read:
brk_spi_read:
    lda #$0
    sta SPI_BUFFER

.bit_loop:
    stx SPI_BITMASK

    lda IO_VIA1_PORTA
    jsr spi_clk
    beq .got_zero

    ; Got a 1 
    lda SPI_BUFFER
    ora SPI_BITMASK
    sta SPI_BUFFER

.got_zero:
    ; Invert the bitmask
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

    cpx #0
    bne .bit_loop

    lda SPI_BUFFER
    rts

; Toogle the SPI clock and read the recieved Miso bit into A
; Expects A to be the existing value of IO_VIA1_PORTA
spi_clk:
    ; Toggle the SPI clock
    ora #$4 ; Set clock bit (pin 2)
    sta IO_VIA1_PORTA
    and #$FB ; Clear clock bit (pin 2)
    sta IO_VIA1_PORTA

    ; Recieve bit
    lda IO_VIA1_PORTA ; Miso is pin 1
    and #$2
    rts

