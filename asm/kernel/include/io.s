
; Check for and return an available charactor from the input buffer
; The character will be placed in A
; If no character is available A will be set to 0
getc:
    sei
    phx
    lda READ_POINTER
    cmp WRITE_POINTER
    bne _getc_character_available ;Is the read pointer behind the write pointer?
    lda #$0
    jmp _getc_return

_getc_character_available:
    ldx READ_POINTER
    lda INPUT_BUFFER, x
    inc READ_POINTER

_getc_return:
    plx
    cli
    rts

; Put character from A into output
putc:
    pha
        jsr print_char ; Temporary, refactor to remove double call
    pla
