    .org $C000
    
    .include "../kernel/include/macros.s"
    .include "../kernel/include/constants.s"
    .include "../kernel/include/utils/hex_utils.s"
    .include "../kernel/include/io/io_generic.s"

    .include "../kernel/include/io/graphic/graphic.s"
    .include "../kernel/include/io/graphic/io_graphic.s"

hello_msg:
    .string "Hello! This is a test string!"

reset:  
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    jsr display_init

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER
    sta CURRENT_LINE
    sta CURRENT_COLUMN

.screen_top:
    ldx #GRAPHICS_ADDR_FRAMEBUFFER_HIGH
    stx GRAPHICS_ADDR_HIGH
    ldx #GRAPHICS_ADDR_FRAMEBUFFER_LOW
    stx GRAPHICS_ADDR_LOW
    ldx #0

.print_loop:
    putstr_addr hello_msg
;jsr newline

;   inx
;   cpx #60
;   bne .print_loop

;   ldx #0
;   ldy #0
;   jsr goto_position
    jmp .screen_top 

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq
