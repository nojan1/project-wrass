scan_keyboard:
    phx
    pha

    lda IO_CONTROL
    and #KEYBOARD_INPUT
    beq exit

    lda KEYBOARD_FLAGS
    and #KEYBOARD_RELEASE   ; check if we're releasing a key
    beq read_key   ; otherwise, read the key

    lda KEYBOARD_FLAGS
    eor #KEYBOARD_RELEASE   ; flip the releasing bit
    sta KEYBOARD_FLAGS
    lda IO_SYSTEM_VIA_PORTB      ; read key value that's being released
    cmp #$12       ; left shift
    beq shift_up
    cmp #$59       ; right shift
    beq shift_up
    jmp exit

shift_up:
    lda KEYBOARD_FLAGS
    eor #KEYBOARD_SHIFT  ; flip the shift bit
    sta KEYBOARD_FLAGS
    jmp exit

read_key:
    lda IO_SYSTEM_VIA_PORTB
    cmp #$f0        ; if releasing a key
    beq key_release ; set the releasing bit
    cmp #$12        ; left shift
    beq shift_down
    cmp #$59        ; right shift
    beq shift_down

    sta KEYCODE_RAW

    tax
    lda KEYBOARD_FLAGS
    and #KEYBOARD_SHIFT
    bne shifted_key

    lda keymap, x   ; map to character code
    jmp push_key

shifted_key:
    lda keymap_shifted, x   ; map to character code

push_key:
    ldx WRITE_POINTER
    sta INPUT_BUFFER, x
    inc WRITE_POINTER
    jmp exit

shift_down:
    lda KEYBOARD_FLAGS
    ora #KEYBOARD_SHIFT
    sta KEYBOARD_FLAGS
    jmp exit

key_release:
    lda KEYBOARD_FLAGS
    ora #KEYBOARD_RELEASE
    sta KEYBOARD_FLAGS

exit:
    pla
    plx
    rts