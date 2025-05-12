; Open a file by its name, will only look in the current directory
; Expects a pointer to a filename string to be in PARAM_16_1 
; Will set ERROR and return with Carry flag high on error
open_file:
    stz ERROR

    ; Make sure the SD card is initialized
    lda SD_CARD_STATUS
    cmp #SD_CARD_INITIALIZED
    beq .sd_card_ready

    lda #ERROR_SD_CARD_NOT_INITIALIZED
    sta ERROR ; If not error out
    jmp .on_error

.sd_card_ready:
    jsr find_file_entry_in_current_directory
    lda ERROR
    bne .on_error
    
    ; We found the file! Setup the FILE_HANDLE for the file
    lda #FILE_HANDLE_STATUS_OPENED
    sta FILE_HANDLE_STATUS

    ; Cluster address
    ldy #$14 + 1
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_CURRENT_CLUSTER + 3
    ldy #$14 + 0
    sta FILE_HANDLE_CURRENT_CLUSTER + 2
    ldy #$1A + 1
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_CURRENT_CLUSTER + 1
    ldy #$1A + 0
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_CURRENT_CLUSTER + 0

    ; Filesize
    ldy #$1C + 3
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_BYTES_REMAINING + 3
    ldy #$1C + 2
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_BYTES_REMAINING + 2
    ldy #$1C + 1
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_BYTES_REMAINING + 1  
    ldy #$1C + 0
    lda (TERM_16_1_LOW), y
    sta FILE_HANDLE_BYTES_REMAINING + 0

    stz FILE_HANDLE_CURRENT_SECTOR_OFFSET
    stz FILE_HANDLE_CURRENT_CHUNK_OFFSET
    
    clc
    bra .on_success

.on_error:
    sec
.on_success
    rts

; Read the next chunk of 256 bytes from the open file, PARAM_16_1 will point to it
; The number of bytes that are actual file bytes are returned in X (makes sense when EOF is hit)
; Will set ERROR and return with Carry flag high on error
read_file:
    stz ERROR

    ; Make sure the SD card is initialized
    lda SD_CARD_STATUS
    cmp #SD_CARD_INITIALIZED
    beq .sd_card_ready

    lda #ERROR_SD_CARD_NOT_INITIALIZED
    sta ERROR ; If not error out
    jmp .on_error

.sd_card_ready:
    ; Check the status of the file handle, if we are at EOF set X to 0 and return
    lda FILE_HANDLE_STATUS
    cmp #FILE_HANDLE_STATUS_EOF
    bne .not_end_of_file
    ldx #0
    clc
    bra .done

.not_end_of_file:
    cmp #FILE_HANDLE_STATUS_OPENED
    beq .status_correct

    lda #SD_READ_ERROR
    sta ERROR
    bra .on_error

.status_correct:
    ; Setup the CURRENT_CLUSTER variable to point at our active file cluster
    lda FILE_HANDLE_CURRENT_CLUSTER + 0
    sta CURRENT_CLUSTER + 0
    lda FILE_HANDLE_CURRENT_CLUSTER + 1
    sta CURRENT_CLUSTER + 1
    lda FILE_HANDLE_CURRENT_CLUSTER + 2
    sta CURRENT_CLUSTER + 2
    lda FILE_HANDLE_CURRENT_CLUSTER + 3
    sta CURRENT_CLUSTER + 3

.read_next_chunk:
    ; We have more to read then...
    lda FILE_HANDLE_CURRENT_CHUNK_OFFSET
    cmp #2 ; 0 indexed chunk offset, there are 2 "chunks" (256 bytes) on each sector (512)
    beq .read_next_sector ; If it was 2 then we have already read the last chunk and needs the next sector
    bra .read_data

.read_next_sector:  
    stz FILE_HANDLE_CURRENT_CHUNK_OFFSET ; Reset chunk offset
    inc FILE_HANDLE_CURRENT_SECTOR_OFFSET
    lda FILE_HANDLE_CURRENT_SECTOR_OFFSET
    cmp SECTORS_PER_CLUSTER ; Are we already at the last sector of the cluster
    beq .read_next_cluster
    bra .read_data

.read_next_cluster:
    stz FILE_HANDLE_CURRENT_SECTOR_OFFSET ; Reset sector offset
    
    ; We need to follow the cluster chain to find the next cluster of the file...
    jsr try_advance_to_next_cluster
    lda ERROR
    bne .on_error

.read_data:
    ; Now we are ready to read the data
    ldx FILE_HANDLE_CURRENT_SECTOR_OFFSET
    jsr read_cluster

    lda ERROR
    bne .on_error

    ; Setup the data pointer before returning... first set the base address..
    lda #<SD_BUFFER
    sta PARAM_16_1 + 0

    lda #>SD_BUFFER
    sta PARAM_16_1 + 1

    ;.. then add the chunk offset to the high byte
    clc
    lda FILE_HANDLE_CURRENT_CHUNK_OFFSET
    adc PARAM_16_1 + 0
    sta PARAM_16_1 + 0

    ;.. then increment the chunk offset for the next read
    inc FILE_HANDLE_CURRENT_CHUNK_OFFSET

    ; Now we need to decrement the file size and return the remaing file size (mod 256) in X
    lda FILE_HANDLE_BYTES_REMAINING + 0
    pha ; Save in case the size decrement underflows(?)

    sec
    lda FILE_HANDLE_BYTES_REMAINING + 0
    sbc #>256
    sta FILE_HANDLE_BYTES_REMAINING + 0
    lda FILE_HANDLE_BYTES_REMAINING + 1
    sbc #<256
    sta FILE_HANDLE_BYTES_REMAINING + 1
    lda FILE_HANDLE_BYTES_REMAINING + 2
    sbc #0
    sta FILE_HANDLE_BYTES_REMAINING + 2
    lda FILE_HANDLE_BYTES_REMAINING + 3
    sbc #0 
    sta FILE_HANDLE_BYTES_REMAINING + 3

    bcs .out_of_bytes

    plx ; Throw away value
    ldx FILE_HANDLE_BYTES_REMAINING + 0

    clc
    bra .done

.out_of_bytes:
    lda #FILE_HANDLE_STATUS_EOF
    sta FILE_HANDLE_STATUS

    plx ; Put the original value of the lower byte into X

    clc
    bra .done

.on_error:
    sec
.done:
    rts