;; Graphic addresses
GRAPHICS_ADDR_FRAMEBUFFER_LOW = $00 
GRAPHICS_ADDR_FRAMEBUFFER_HIGH = $C0

GRAPHICS_ADDR_COLORATTRIBUTES_LOW = $C1
GRAPHICS_ADDR_COLORATTRIBUTES_HIGH = $D2

GRAPHICS_ADDR_TILEMAP_LOW = $82 
GRAPHICS_ADDR_TILEMAP_HIGH = $E5

GRAPHICS_ADDR_COLORS_LOW = $82 
GRAPHICS_ADDR_COLORS_HIGH = $ED

display_init:
    lda #1
    sta GRAPHICS_INCREMENT
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #0
    sta GRAPHICS_ADDR_LOW

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
    lda GRAPHICS_INCREMENT

    sty GRAPHICS_INCREMENT ; We wil use the auto increment register
.keep_incrementing:
    ldy GRAPHICS_DATA

    dex
    bne .keep_incrementing

    sta GRAPHICS_INCREMENT ; Reset to what it was before
    pla
    ply
    plx
    rts