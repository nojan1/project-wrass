;; Graphic addresses
GRAPHICS_ADDR_FRAMEBUFFER_LOW = $00
GRAPHICS_ADDR_FRAMEBUFFER_HIGH = $00

GRAPHICS_ADDR_COLORATTRIBUTES_LOW = $00
GRAPHICS_ADDR_COLORATTRIBUTES_HIGH = $08

GRAPHICS_ADDR_TILEMAP_LOW = $00
GRAPHICS_ADDR_TILEMAP_HIGH = $10

GRAPHICS_ADDR_COLORS_LOW = $00
GRAPHICS_ADDR_COLORS_HIGH = $18

display_init:
    lda #1
    sta GRAPHICS_INCREMENT

    ; Initialize framebuffer to empty
    lda #0
    ldy #8
set_framebuffer_outer_loop:
    ldx #0
set_framebuffer_inner_loop:
    sta GRAPHICS_DATA
    inx
    bne set_framebuffer_inner_loop
    dey
    bne set_framebuffer_outer_loop

    ; Now initialize color attributes to default
    lda #GRAPHICS_ADDR_COLORATTRIBUTES_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #GRAPHICS_ADDR_COLORATTRIBUTES_LOW
    sta GRAPHICS_ADDR_LOW

    lda #%00010110
    ldy #8
set_colorattribute_outer_loop:
    ldx #0
set_colorattribute_inner_loop:
    sta GRAPHICS_DATA
    inx
    bne set_colorattribute_inner_loop
    dey
    bne set_colorattribute_outer_loop

    ; Set address to top of framebuffer
    lda #0
    lda #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #GRAPHICS_ADDR_FRAMEBUFFER_LOW
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