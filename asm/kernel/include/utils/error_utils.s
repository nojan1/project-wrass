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

UNSUPPORTED_NUMBER_OF_FATS_string:
    .string "UNSUPPORTED_NUMBER_OF_FATS"

UART_RECIEVE_BUFFER_OVERFLOW_string:
    .string "UART_RECIEVE_BUFFER_OVERFLOW"

SD_ILLEGAL_COMMAND_string:
    .string "SD_ILLEGAL_COMMAND"

FILE_NOT_FOUND_string:
    .string "FILE_NOT_FOUND"

SD_CARD_NOT_INITIALIZED_string:
    .string "SD CARD NOT INITIALIZED"

error_messages:
    .db 0x0 ; Dummy
    .word SD_CARD_INIT_FAILED_string 
    .word SD_CARD_BLOCKSET_FAILED_string
    .word SD_READ_TIMEOUT_string
    .word SD_READ_ERROR_string
    .word INVALID_MBR_string
    .word NO_VALID_PARTITION_string
    .word UNSUPPORTED_NUMBER_OF_FATS_string
    .word UART_RECIEVE_BUFFER_OVERFLOW_string
    .word SD_ILLEGAL_COMMAND_string
    .word FILE_NOT_FOUND_string
    .word SD_CARD_NOT_INITIALIZED_string

; Checks for error flag and prints the error
; Sets the carry flag if there was an error
; Mutates: PARAM_16_1
check_and_print_error:
    clc

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

    sec

.no_error:
    ply
    pla
    rts