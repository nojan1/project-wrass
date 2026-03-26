
    .include "setup.s"

SCRATCH = ZP_USAGE_TOP + 1
GPU_BITMAP_MODE = 1 << 2

    lda #GPU_BITMAP_MODE
    sta GRAPHICS_CONTROL

    ldy #0
    sty GRAPHICS_ADDR_LOW
    sty GRAPHICS_ADDR_HIGH

    ldy #0
.next_row:

    ldx #0
    jsr goto_bitmap_x_y
.next_column:
    txa
    lsr
    lsr
    and #$0F
    sta SCRATCH

    asl
    asl
    asl
    asl
    ora SCRATCH
    sta GRAPHICS_DATA

    inx
    cpx #80 ; 80 bytes for 160 pixels
    bne .next_column

    iny
    cpy #120
    beq .done
    bra .next_row

.done:    
    jmp *

goto_bitmap_x_y:
    pha
    
    ; Calculate HIGH
    ; HIGH = ROW >> 1
    tya
    lsr
    sta GRAPHICS_ADDR_HIGH

    ; Calculate LOW
    ; LOW = (ROW << 7) | (COL >> 1)
    txa
    lsr
    sta VAR_8BIT_1
    tya
    .repeat 7
    asl
    .endr
    ora VAR_8BIT_1
    sta GRAPHICS_ADDR_LOW

    pla
    rts
