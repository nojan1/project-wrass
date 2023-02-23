    .org $C000
    
    .include "../kernel/include/constants.s"

reset:  
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    lda #1
    sta GRAPHICS_INCREMENT

loop:
    lda #0
    sta GRAPHICS_ADDR_LOW
    sta GRAPHICS_ADDR_HIGH

    lda #(65-32)
    sta GRAPHICS_DATA

    jmp loop

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq
