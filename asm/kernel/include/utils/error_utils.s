error_text:
    .string "Error: "

; Checks for error flag and prints the error
check_and_print_error:
    pha
    lda ERROR
    beq .no_error

    putstr_addr error_text

    lda ERROR
    jsr puthex
    jsr newline

.no_error:
    pla
    rts