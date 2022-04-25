error_text:
    .string "Error: "

SD_CARD_INIT_FAILED_string:
    .string "SD_CARD_INIT_FAILED"

SD_CARD_BLOCKSET_FAILED_string:
    .string "SD_CARD_BLOCKSET_FAILED"

SD_READ_TIMEOUT_string:
    .string "SD_READ_TIMEOUT"

SD_READ_ERROR_string:
    .string "SD_READ_ERROR"

INVALID_MBR_string:
    .string "INVALID_MBR"

NO_VALID_PARTITION_string:
    .string "NO_VALID_PARTITION_FOUND"

error_messages:
    .db 0x0 ; Dummy
    .word SD_CARD_INIT_FAILED_string 
    .word SD_CARD_BLOCKSET_FAILED_string
    .word SD_READ_TIMEOUT_string
    .word SD_READ_ERROR_string
    .word INVALID_MBR_string
    .word NO_VALID_PARTITION_string

; Checks for error flag and prints the error
; Mutates: PARAM_16_1
check_and_print_error:
    pha
    phy
    ldy ERROR
    beq .no_error

    putstr_addr error_text

    lda error_messages, y
    sta PARAM_16_1
    iny
    lda error_messages, y
    sta PARAM_16_1+1
    jsr putstr
    jsr newline

.no_error:
    ply
    pla
    rts