welcome_message_string:
    .string "Welcome to Wrass! monitor, have fun"

print_banner:
    .ifndef NO_GPU
    ldx #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    stx GRAPHICS_ADDR_HIGH

    ldx #0
    stx GRAPHICS_ADDR_LOW
    lda #98
    jsr gpu_putsc

    lda #99
    .rept 38
    jsr gpu_putsc
    .endr

    lda #100
    jsr gpu_putsc

    jsr gpu_newline

    lda #101
    jsr gpu_putsc

    lda #" "
    jsr putc
    .endif

    putstr_addr welcome_message_string  

    .ifndef NO_GPU
    ldx #39
    ldy #1
    jsr gpu_goto_position

    lda #101
    jsr gpu_putsc

    jsr gpu_newline

    lda #103
    jsr gpu_putsc

    lda #99
    .rept 38
    jsr gpu_putsc
    .endr

    lda #104
    jsr gpu_putsc

    ldx #0
    ldy #3
    jsr gpu_goto_position
    .endif
    
    jsr newline

    rts
