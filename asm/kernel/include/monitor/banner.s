welcome_message_string:
    .string "Welcome to Wrass! monitor, have fun"

print_banner:

    ldx #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    stx GRAPHICS_ADDR_HIGH

    ldx #0
    stx GRAPHICS_ADDR_LOW

    lda #98
    jsr putsc

    lda #99
    .rept 38
    jsr putsc
    .endr

    lda #100
    jsr putsc

    jsr newline

    lda #101
    jsr putsc

    lda #" "
    jsr putc

    putstr_addr welcome_message_string  

    ldx #39
    ldy #1
    jsr goto_position

    lda #101
    jsr putsc

    jsr newline

    lda #103
    jsr putsc

    lda #99
    .rept 38
    jsr putsc
    .endr

    lda #104
    jsr putsc

    ldx #0
    ldy #4
    jsr goto_position

    rts