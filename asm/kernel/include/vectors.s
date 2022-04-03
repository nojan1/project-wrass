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

    ; LCD SETUP
    lda #%11111111 ; Set all pins on port B to output
    sta LCD_DDRB
    lda #%11100000 ; Set top 3 pins on port A to output
    sta LCD_DDRA

    lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction
    lda #%00001110 ; Display on; cursor on; blink off
    jsr lcd_instruction
    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr lcd_instruction
    lda #$00000001 ; Clear display
    jsr lcd_instruction
    ;;;;

    ; KEYBOARD INTERFACE SETUP
    lda #0
    sta IO_VIA2_DDRA ; All pins are input

    jsr monitor_loop