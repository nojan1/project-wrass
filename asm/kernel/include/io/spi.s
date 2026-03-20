spi_init:
    ; All pins on PORTA of system VIA is output
    lda #$FF
    sta IO_SYSTEM_VIA_DDRA
    
    ; No SPI device selected, clocks low and all output selects inactive
    lda #0b11100000
    sta IO_SYSTEM_VIA_PORTA

    lda #(SPI_MODE_0 | SPI_FASTERCLOCK)
    sta SPI_CONFIG

    jsr spi_clock_inactive

    rts


; TEMP
MOSI=0
MISO=0
SPI_IN=$FA
SPI_OUT=$FB

; Set the active SPI device to the line number in A
; bit 0-2 are address
spi_set_device:
    and #$07
    pha
    lda IO_SYSTEM_VIA_PORTA
    and #$f1
    sta IO_SYSTEM_VIA_PORTA
    pla
    beq .spi_set_no_device ; if we are deselecting (addr==0) then we can skip the or operation
    ora IO_SYSTEM_VIA_PORTA
    sta IO_SYSTEM_VIA_PORTA
.spi_set_no_device:    
    rts

; Set clock to inactive state based on current CPOL
spi_clock_inactive:
    pha
    lda SPI_CONFIG
    and #CPOL_INVERTED
    bne .set_clock_inactive_inverted

    lda IO_SYSTEM_VIA_PORTA
    and #(~SPI_CLOCK)
    sta IO_SYSTEM_VIA_PORTA

    jmp .spi_clock_inactive_done

.set_clock_inactive_inverted:
    lda IO_SYSTEM_VIA_PORTA
    ora #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA

.spi_clock_inactive_done:
    pla
    rts

; Sends the byte stored in A over spi, toggling the clock
; Puts the return value into A
spi_transcieve:
; brk spi_transc
    jsr spi_clock_inactive

    phx
    phy
    ldx #9
    
    ; Put the SPI mode number into Y
    pha
    clc
    lda SPI_CONFIG
    and #(CPOL_INVERTED | CPHASE_INVERTED)
    lsr
    lsr
    lsr
    lsr
    tay
    pla

    ; Store value to send in SPI_OUT
    sta SPI_OUT

    ; Clear SPI_IN
    lda #0
    sta SPI_IN

.spi_transcieve_next_byte:
    dex
    beq .spi_all_bytes_transcieved
    jsr spi_delay

    lda IO_SYSTEM_VIA_PORTA

    cpy #0
    bne .spi_transcieve_next_byte_check_mode_1
    ; Mode 0
    jsr spi_set_mosi
    ora #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA

    jsr spi_delay
    jsr spi_sample_miso
    and #(~SPI_CLOCK)
    sta IO_SYSTEM_VIA_PORTA
    jmp .spi_transcieve_next_byte

.spi_transcieve_next_byte_check_mode_1:
    cpy #1
    bne .spi_transcieve_next_byte_check_mode_2
    ; Mode 1

    ora #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA
    jsr spi_delay

    jsr spi_sample_miso
    jsr spi_set_mosi
    and #(~SPI_CLOCK)
    sta IO_SYSTEM_VIA_PORTA

    jmp .spi_transcieve_next_byte

.spi_transcieve_next_byte_check_mode_2:
    cpy #2
    bne .spi_transcieve_next_byte_mode_3
    ; Mode 2

    jsr spi_set_mosi
    and #(~SPI_CLOCK)
    sta IO_SYSTEM_VIA_PORTA

    jsr spi_delay

    ora #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA
    jsr spi_sample_miso

    jmp .spi_transcieve_next_byte

.spi_transcieve_next_byte_mode_3:
    ; Mode 3

    and #(~SPI_CLOCK)
    sta IO_SYSTEM_VIA_PORTA
    jsr spi_sample_miso

    jsr spi_delay

    jsr spi_set_mosi
    ora #SPI_CLOCK
    sta IO_SYSTEM_VIA_PORTA

    jmp .spi_transcieve_next_byte


.spi_all_bytes_transcieved:
    jsr spi_clock_inactive
    lda SPI_IN

    ply
    plx

    ; pha
    ; jsr sys_puthex
    ; lda #" "
    ; jsr sys_putc
    ; pla

    rts

;; Take the most significant bit from SPI_OUT and set it on the MOSI line
spi_set_mosi:
    rol SPI_OUT
    bcs .spi_set_mosi_1
    and #(~MOSI)
    sta IO_SYSTEM_VIA_PORTA
    jmp .spi_set_mosi_done
.spi_set_mosi_1:
    ora #MOSI
    sta IO_SYSTEM_VIA_PORTA
.spi_set_mosi_done:
    rts

;; Sample MISO line and shift bit in towards the most significant bit in SPI_IN
spi_sample_miso:
    lda IO_SYSTEM_VIA_PORTA
    and #MISO
    bne .spi_sample_miso_high
    clc
    jmp .spi_sample_miso_done
.spi_sample_miso_high:
    sec
.spi_sample_miso_done:
    rol SPI_IN
    lda IO_SYSTEM_VIA_PORTA
    rts

spi_delay:
    phx
    pha
    lda SPI_CONFIG
    and #0b00001111
    tax
.spi_delay_cont:
    dex
    bne .spi_delay_cont

    pla
    plx
    rts
