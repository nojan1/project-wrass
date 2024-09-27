SPI_BUFFER = VAR_8BIT_1
SPI_BITMASK = VAR_8BIT_2

SPI_DEVICES_ENABLED = 1 << 0
SPI_DEVICES_DISABLED = 0 << 0

MOSI = 1
MISO = 2
SPI_CLOCK = 4

; Set the active SPI device to the line number in A
; bit 0 set to 0 disables all devies
; bit 1-3 are address
spi_set_device:
    and #$0F
    asl
    asl
    asl
    asl
    sta IO_SYSTEM_VIA_PORTA
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
    lda IO_SYSTEM_VIA_PORTA
    ora #MOSI

    jmp .clock

.send_zero:
    lda IO_SYSTEM_VIA_PORTA
    and #($FE & ~MOSI)

.clock:
    jsr spi_clk
    beq .got_zero

    ; Got a 1 
    lda SPI_BUFFER
    ora SPI_BITMASK
    sta SPI_BUFFER

.got_zero:
    ; No need to set since SPI_BUFFER was initialized to 0 from the start

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
    lda #$0
    sta SPI_BUFFER

.bit_loop:
    stx SPI_BITMASK

    lda IO_SYSTEM_VIA_PORTA
    jsr spi_clk
    beq .got_zero

    ; Got a 1 
    lda SPI_BUFFER
    ora SPI_BITMASK
    sta SPI_BUFFER

.got_zero:
    ; No need to set since SPI_BUFFER was initialized to 0 from the start

    ; Prepare to process next bit
    txa
    lsr
    tax

    cpx #0
    bne .bit_loop

    lda SPI_BUFFER
    rts

; Toogle the SPI clock and read the recieved Miso bit into A
; Expects A to be the existing value of IO_SYSTEM_VIA_PORTA
spi_clk:
    jsr spi_delay

    ; Toggle the SPI clock
    ora #SPI_CLOCK ; Set clock bit (pin 2)
    sta IO_SYSTEM_VIA_PORTA

    jsr spi_delay

    and #(~SPI_CLOCK) ; Clear clock bit (pin 2)
    sta IO_SYSTEM_VIA_PORTA

    jsr spi_delay

    ; Recieve bit
    lda IO_SYSTEM_VIA_PORTA
    and #MISO
    rts


spi_delay:
    phx
    ldx #1
spi_delay_cont:
    dex
    bne spi_delay_cont

    plx
    rts