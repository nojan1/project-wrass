irq:
    phx
    pha
    lda KEYBOARD_FLAGS
    and #KEYBOARD_RELEASE   ; check if we're releasing a key
    beq read_key   ; otherwise, read the key

    lda KEYBOARD_FLAGS
    eor #KEYBOARD_RELEASE   ; flip the releasing bit
    sta KEYBOARD_FLAGS
    lda IO_VIA2_PORTA      ; read key value that's being released
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
    lda IO_VIA2_PORTA
    cmp #$f0        ; if releasing a key
    beq key_release ; set the releasing bit
    cmp #$12        ; left shift
    beq shift_down
    cmp #$59        ; right shift
    beq shift_down

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
    rti

nmi:
    nop
    rti

reset:
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER
    sta KEYBOARD_FLAGS
    sta CURRENT_LINE
    sta CURRENT_COLUMN

    jsr display_init

    ; KEYBOARD INTERFACE SETUP
    lda #0
    sta IO_VIA2_DDRA ; All pins are input

    jsr monitor_loop_start