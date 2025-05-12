; Send the 72 dummy pulses required to boot an SD-card
sd_dummy_boot_pulses:
    phx
    pha

    ; Make sure no device is selected
    lda #SPI_DEVICES_DISABLED
    jsr spi_set_device

    jsr sd_delay

    ldx #10
.send_pulse:
    lda #$FF
    jsr spi_transcieve

    dex
    bne .send_pulse

    pla
    plx
    rts

; Setup SPI modes and initialize SD card
; Mutates: A, X, Y
sd_init:
    ; Setup SPI mode 0, with 2 wait cycles
    lda #(SPI_MODE_0 | 2)
    sta SPI_CONFIG
    jsr spi_clock_inactive

    jsr sd_dummy_boot_pulses

    ; Send CMD0
    jsr sd_cmd0

    ; Check if there was an error and bail if that was the case
    pha
    lda ERROR
    bne .sd_init_done
    pla

    ; Send CMD8 
    jsr sd_cmd8

    ; A version 2 card will return OK, a version 1 card will return illegal command
    pha
    lda ERROR
    beq .sd_ver2_or_later
    cmp #SD_ILLEGAL_COMMAND
    beq .sd_ver1

    pla
    bra .sd_init_done

.sd_ver1:
    pla
    putstr_addr ver1_not_supported
    jsr newline
    
    pha
    bra .sd_init_done

.sd_ver2_or_later:
    pla
    jsr sd_acmd41
    pha
    jsr newline

.sd_init_done:
    ; Once initialized we can speed up, setup SPI mode 0, with 1 wait cycles
    lda #(SPI_MODE_0 | 1)
    sta SPI_CONFIG

    lda #SD_CARD_INITIALIZED
    sta SD_CARD_STATUS

    pla
    rts

ver1_not_supported:
    .string "Version 1 card not supported..yet"

; Send CMD to SD-Card
; Command number in A
; CRC in Y
; Num response bytes in X
; 32 bit arguments in TERM_32_1
sd_cmd:
    sei

    pha
    lda #0
    sta ERROR

    ; Send sync package before select
    lda #$FF
    jsr spi_transcieve

    lda #SD_CARD_SPI_DEVICE
    jsr spi_set_device

    jsr sd_delay

    ; Send sync package after select
    lda #$FF
    jsr spi_transcieve
    pla

    ; SD command field is start bit 01 follow by 6 bit command 
    and #$3F
    ora #$40
    jsr spi_transcieve

    ; Send parameters (32 bit)
    lda TERM_32_1_1
    jsr spi_transcieve
    lda TERM_32_1_2
    jsr spi_transcieve
    lda TERM_32_1_3
    jsr spi_transcieve
    lda TERM_32_1_4
    jsr spi_transcieve

    ; Send CRC and stop bit
    tya
    ora #1
    jsr spi_transcieve

    ; Wait for the SD-card to start returning a response
    jsr sd_wait_for_response 
    bcs .sd_cmd_no_response

.sd_cmd_first_byte_read:
    ldy #0
    sta SD_BUFFER, y

    ; First byte is expected to be an R1, check if it is okey
    and #$FE
    bne .sd_cmd_illegal_command
    
.sd_cmd_next_response_byte:
    iny
    dex
    beq .sd_cmd_done

    lda #$FF
    jsr spi_transcieve
    sta SD_BUFFER, y
    jmp .sd_cmd_next_response_byte

.sd_cmd_illegal_command:
    lda #SD_ILLEGAL_COMMAND
    sta ERROR
    lda SD_BUFFER, y
    bra .sd_cmd_done

.sd_cmd_no_response:
    pha
    lda #SD_READ_TIMEOUT
    sta ERROR
    pla

.sd_cmd_done:
    pha
    ; Send sync package before deselect
    lda #$FF
    jsr spi_transcieve

    lda #SPI_DEVICES_DISABLED
    jsr spi_set_device

    jsr sd_delay

    ; Send sync package after deselect
    lda #$FF
    jsr spi_transcieve
    pla

    cli
    rts

; Send CMD0 to SD-Card
; Mutates: A
sd_cmd0:
    sei
    phx
    phy

    stz TERM_32_1_1
    stz TERM_32_1_2
    stz TERM_32_1_3
    stz TERM_32_1_4

    lda #0 ; Command index
    ldx #1 ; Number of response bytes, including R1
    ldy #%10010100 ; CRC

    jsr sd_cmd

    ply
    plx
    cli
    rts

; Send CMD8 to SD-Card
; Mutates: A
sd_cmd8:
    sei
    phx
    phy

    lda #0
    sta TERM_32_1_1
    sta TERM_32_1_2

    ; 4 bit zero and 3.3volts
    lda #%00000001
    sta TERM_32_1_3

    ; Check pattern
    lda #%10101010
    sta TERM_32_1_4

    lda #8 ; Command index
    ldx #5 ; Number of response bytes, including R1
    ldy #%10000110 ; CRC

    jsr sd_cmd

    ply
    plx
    cli
    rts

; Send CMD8 to SD-Card
; Mutates: A
sd_cmd58:
    sei
    phx
    phy

    lda #0
    sta TERM_32_1_1
    sta TERM_32_1_2
    sta TERM_32_1_3
    sta TERM_32_1_4

    lda #58 ; Command index
    ldx #5 ; Number of response bytes, including R1
    ldy #0 ; CRC (ignored)

    jsr sd_cmd

    ply
    plx
    cli
    rts

; Send ACMD41 to SD-Card
; Mutates: A
sd_acmd41:
    sei
    phx
    phy

    ldy #20

.try_acmd41_again:
    dey
    beq .done_waiting_acmd41

    ; phy
    ; First we need to send a CMD55
    lda #0
    sta TERM_32_1_1
    sta TERM_32_1_2
    sta TERM_32_1_3
    sta TERM_32_1_4

    lda #55 ; Command index
    ldx #1 ; Number of response bytes
    ldy #0 ; CRC (ignored)

    jsr sd_cmd

    ; Then we can send (A)CMD41
    lda #$40
    sta TERM_32_1_1

    lda #41 ; Command index
    ldx #1 ; Number of response bytes
    ldy #0 ; CRC (ignored)

    jsr sd_cmd

    ; BUG!!! A should have the last value.. but doesn't for some reason???
    ldy #0
    lda SD_BUFFER, y

    cmp #0
    beq .acmd41_complete
    jsr sd_init_wait
    jmp .try_acmd41_again

.done_waiting_acmd41: 
    pha
    lda #SD_READ_TIMEOUT
    sta ERROR
    pla

.acmd41_complete:
    ply
    plx
    cli
    rts


; Send CMD16 (block set) to SD-Card, this will set the block size to 512 bytes
; sd_cmd16:
;     sei
;     pha

;     lda #0
;     sta ERROR

;     lda #SD_CARD_SPI_DEVICE
;     jsr spi_set_device

;     ; Send startbits and command index 16
;     lda #%01010000
;     jsr spi_transcieve

;     ; Send parameters (32 bit), for blocksize of 512
;     .repeat 2
;     lda #0
;     jsr spi_transcieve   
;     .endrep

;     lda #2
;     jsr spi_transcieve   

;     lda #0
;     jsr spi_transcieve   

;     ; Send CRC (ignored) and stop bit
;     lda #$1
;     jsr spi_transcieve

;     ; Wait for the SD-card to start returning a response
;     jsr sd_wait_for_response 
;     bcs .no_response

;     cmp #0 ; Only the "In idle state" flag should be set
;     beq .done

; .no_response:
;     lda #SD_CARD_BLOCKSET_FAILED
;     sta ERROR

; .done:
;     pla
;     cli
;     rts

; Toggles the SPI clock and waits for Miso to go low
; This expects the SD card to be the selected device
; If a response is recieved before timeout A will be zero
; Mutates: A, X
sd_wait_for_response:
    ldx #15

.keep_waiting:
    dex
    beq .timeout

    lda #$FF
    jsr spi_transcieve

    ; pha
    ; jsr sys_puthex
    ; lda #" "
    ; jsr sys_putc
    ; pla

    cmp #$FF
    beq .keep_waiting
    clc
    bra .return

.timeout:
    sec ; Set carry flag to signal timeout

.return:
    rts

sd_delay:
    lda #$FF
.keep_waiting
    sec
    sbc #1
    beq .delay_done
    jmp .keep_waiting
.delay_done:
    rts

; Some waiting time after SD card init
sd_init_wait:
    phy
    phx
    ldx #$FF
.sd_init_wait_outer:
    dex
    beq .sd_init_wait_done

    ldy #$FF
.sd_init_wait_inner:
    dey
    beq .sd_init_wait_outer

    nop
    jmp .sd_init_wait_inner

.sd_init_wait_done:
    plx
    ply
    rts