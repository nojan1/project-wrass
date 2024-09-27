SD_CARD_SPI_DEVICE = 0

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

; Send CMD0 to SD-Card
; Mutates: A
sd_cmd0:
    sei

    lda #0
    sta ERROR

    ; Send sync package before select
    lda #$FF
    jsr spi_transcieve

    lda #(SPI_DEVICES_ENABLED | (SD_CARD_SPI_DEVICE << 1))
    jsr spi_set_device

    jsr sd_delay

    ; Send sync package after select
    lda #$FF
    jsr spi_transcieve

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
    bcs .no_response

    jsr sys_puthex

    cmp #1 ; Only the "In idle state" flag should be set
    beq .done

    pha
    lda #SD_CARD_INIT_FAILED
    sta ERROR
    pla
    jmp .done

.no_response:
    pha
    lda #SD_READ_TIMEOUT
    sta ERROR
    pla

.done:
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

sd_delay:
    lda #$FF
.keep_waiting
    sec
    sbc #1
    beq .delay_done
    jmp .keep_waiting
.delay_done:
    rts


; Send CMD16 (block set) to SD-Card, this will set the block size to 512 bytes
; sd_cmd16:
;     sei
;     pha

;     lda #0
;     sta ERROR

;     lda #(SPI_DEVICES_ENABLED | (SD_CARD_SPI_DEVICE << 1))
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

    cmp #$FF
    beq .keep_waiting
    clc
    jmp .return

.timeout:
    sec ; Set carry flag to signal timeout

.return:
    rts

init_sd:
    rts

; init_sd:
;     jsr sd_cmd0
;     jsr check_and_print_error

;     jsr sd_cmd16
;     jsr check_and_print_error

;     ; Set the block address
;     lda #0
;     sta LBA_ADDRESS + 0
;     sta LBA_ADDRESS + 1
;     sta LBA_ADDRESS + 2
;     sta LBA_ADDRESS + 3

;     jsr sd_read_block
;     jsr check_and_print_error

;     jsr parse_mbr
;     jsr check_and_print_error

;     lda PARTITION_LBA + 0
;     sta LBA_ADDRESS + 3
;     lda PARTITION_LBA + 1
;     sta LBA_ADDRESS + 2
;     lda PARTITION_LBA + 2
;     sta LBA_ADDRESS + 1
;     lda PARTITION_LBA + 3
;     sta LBA_ADDRESS + 0

;     jsr sd_read_block
;     jsr check_and_print_error

;     jsr parse_fat_header
;     jsr check_and_print_error

;     rts