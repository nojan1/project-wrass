    .dsect
    .org $7F00
CELLS:
    .fill 64 * 32
ALT_CELLS:
    .fill 64 * 32
    .dend

CELLS_PTR = ZP_USAGE_TOP
R_SEED = CELLS_PTR + 2

    .include "setup.s"

    ; Address for color index 1
    lda #GRAPHICS_ADDR_COLORS_HIGH
    sta GRAPHICS_ADDR_HIGH
    lda #1
    sta GRAPHICS_ADDR_LOW

    lda #$1a
    sta GRAPHICS_DATA

    lda #<CELLS
    sta CELLS_PTR
    lda #>CELLS
    sta CELLS_PTR + 1

    jsr draw_cells

    ;exit to avoid bugs
    rts

count_neighbours:
    


    rts

draw_cells:
    lda #0
    ldy #(1 << 4 | 0)
    jsr sys_clear_screen

    stz GRAPHICS_ADDR_HIGH
    stz GRAPHICS_ADDR_LOW

    ldx #(2048/256)
_draw_loop_outer:
    ldy #0
_draw_loop_inner:
    lda (CELLS_PTR), y    
    sta GRAPHICS_DATA
    iny
    bne _draw_loop_inner

    dex
    beq _draw_done

    lda CELLS_PTR
    clc

_draw_done:
    rts

    .include "include/rand.s"