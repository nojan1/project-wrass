
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
    rts

; Put characters from string in STR_PARAM1 into output
putstr:
    pha
    phy 
    ldy #0

_putstr_loop:
    lda (STR_PARAM1), y
    beq _putstr_end

    jsr putc

    iny
    jmp _putstr_loop

_putstr_end:
    ply
    pla
    rts

; Put newline into output
newline:
    ; TODO: Implement
    rts