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
    lda #GRAPHICS_ADDR_TILEMAP_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #GRAPHICS_ADDR_TILEMAP_LOW
    sta GRAPHICS_ADDR_LOW

    rts

; Clear the screen by filling it with the character in A and color attribute in Y
clear_screen:
    phy

    ; Start by setting the characters
    ldy #GRAPHICS_ADDR_TILEMAP_HIGH
    sty GRAPHICS_ADDR_HIGH
    ldy #GRAPHICS_ADDR_TILEMAP_LOW
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

    txa
    .repeat 6
    lsr
    .endr
    sta GRAPHICS_ADDR_TILEDATA_HIGH

    txa
    .repeat 3
    lsr
    .endr
    sta GRAPHICS_ADDR_TILEDATA_LOW

    ; lda #GRAPHICS_ADDR_TILEDATA_LOW
    ; sta GRAPHICS_ADDR_LOW
    ; lda #GRAPHICS_ADDR_TILEDATA_HIGH
    ; sta GRAPHICS_ADDR_HIGH

    ; ldy #8
    ; jsr advance_graphic_address

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


; Set GRAPHICS_ADDR to address for color attribute coordinate in X, Y
goto_colorattribute_x_y:
    pha
    
    ; Calculate HIGH
    ; HIGH = GRAPHICS_ADDR_COLORATTRIBUTES_HIGH + (ROW >> 2)
    tya
    lsr
    lsr
    ora #GRAPHICS_ADDR_COLORATTRIBUTES_HIGH
    sta GRAPHICS_ADDR_HIGH

    bra _set_xy_low

; ; Set GRAPHICS_ADDR to address for tilemap coordinate in X, Y
goto_tilemap_x_y:
    pha
    
    ; Calculate HIGH
    ; HIGH = ROW >> 2
    tya
    lsr
    lsr
    sta GRAPHICS_ADDR_HIGH

_set_xy_low:
    ; Calculate LOW
    ; LOW = (ROW << 6) | COL
    stx VAR_8BIT_1
    tya
    .repeat 6
    asl
    .endr
    ora VAR_8BIT_1
    sta GRAPHICS_ADDR_LOW

    pla
    rts
