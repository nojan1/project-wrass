welcome_message_string:
    .string "Welcome to the 6502-project monitor, have fun!"

tile_top_left:
    .db $0,$c0,$60,$30,$18,$c,$66,$63

tile_top_right:
    .db $0,$3,$6,$c,$18,$30,$66,$c6

tile_bottom_left:
    .db $3,$26,$4c,$98,$30,$60,$c0,$80

tile_bottom_right:
    .db $c0,$64,$32,$19,$c,$6,$3,$1

print_banner:
    param1_addr tile_top_left
    ldx #$0A
    jsr copy_sprite

    param1_addr tile_top_right
    ldx #$0B
    jsr copy_sprite

    param1_addr tile_bottom_left
    ldx #$0C
    jsr copy_sprite

    param1_addr tile_bottom_right
    ldx #$0D
    jsr copy_sprite

    ldx #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    stx GRAPHICS_ADDR_HIGH

    ldx #2
    stx GRAPHICS_ADDR_LOW

    ldx #$0A
    stx GRAPHICS_DATA

    ldx #$0B
    stx GRAPHICS_DATA

    ldx #82
    stx GRAPHICS_ADDR_LOW

    ldx #$0C
    stx GRAPHICS_DATA
 
    ldx #$0D
    stx GRAPHICS_DATA
    
    ldx #6
    ldy #1
    jsr goto_position

    putstr_addr welcome_message_string
    
    ldx #0
    ldy #4
    jsr goto_position

    rts