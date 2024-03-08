COLOR_ATTRIBUTE_DEFAULT = %00010110
CHARACTER_DEFAULT = 0

gpu_display_init:
    lda #1
    sta GRAPHICS_INCREMENT

    ; Initialize framebuffer to empty
    lda #CHARACTER_DEFAULT
    ldy #COLOR_ATTRIBUTE_DEFAULT
    jsr clear_screen

    ; Set address to top of framebuffer
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #GRAPHICS_ADDR_FRAMEBUFFER_LOW
    sta GRAPHICS_ADDR_LOW

    rts

; Clear the screen by filling it with the character in A and color attribute in Y
clear_screen:
    phy

    ; Start by setting the characters
    ldy #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sty GRAPHICS_ADDR_HIGH
    ldy #GRAPHICS_ADDR_FRAMEBUFFER_LOW
    sty GRAPHICS_ADDR_LOW

    ldy #8
set_framebuffer_outer_loop:
    ldx #0
set_framebuffer_inner_loop:
    sta GRAPHICS_DATA
    inx
    bne set_framebuffer_inner_loop
    dey
    bne set_framebuffer_outer_loop

    ; Now initialize color attributes
    lda #GRAPHICS_ADDR_COLORATTRIBUTES_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #GRAPHICS_ADDR_COLORATTRIBUTES_LOW
    sta GRAPHICS_ADDR_LOW

    pla
    ldy #8
set_colorattribute_outer_loop:
    ldx #0
set_colorattribute_inner_loop:
    sta GRAPHICS_DATA
    inx
    bne set_colorattribute_inner_loop
    dey
    bne set_colorattribute_outer_loop

    rts

; Copy sprite data from the location referenced by PARAM_16_1 into sprite offset by x
copy_sprite:
    pha
    phy

    lda #GRAPHICS_ADDR_TILEMAP_LOW
    sta GRAPHICS_ADDR_LOW
    lda #GRAPHICS_ADDR_TILEMAP_HIGH
    sta GRAPHICS_ADDR_HIGH

    ldy #8
    jsr advance_graphic_address

    lda #1
    sta GRAPHICS_INCREMENT

    ldy #0
.copy_next_byte:
    lda (PARAM_16_1), y
    sta GRAPHICS_DATA

    cpy #8
    beq .done

    iny
    jmp .copy_next_byte

.done:
    ply
    pla
    rts

; Advance graphic address registers by y, x times
advance_graphic_address:
    phx
    phy
    pha
    ; Currently can't read from GPU registers
    ; lda GRAPHICS_INCREMENT 

    sty GRAPHICS_INCREMENT ; We wil use the auto increment register
.keep_incrementing:
    ldy GRAPHICS_DATA

    dex
    bne .keep_incrementing

    lda #1
    sta GRAPHICS_INCREMENT ; Set graphics increment to 1 for now
    pla
    ply
    plx
    rts
