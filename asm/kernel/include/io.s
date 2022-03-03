
; Check for and return an available charactor from the input buffer
; The character will be placed in A
; If no character is available A will be set to 0
getc:
    phx
    ldx READ_POINTER
    cpx WRITE_POINTER
    bcc _getc_character_available ;Is the read pointer behind the write pointer?
    lda #$0
    jmp _getc_return

_getc_character_available:
    lda INPUT_BUFFER, x
    inx
    stx WRITE_POINTER

_getc_return:
    plx
    rts

; Put character from A into output
putc:
    jsr print_char ; Temporary, refactor to remove double call
