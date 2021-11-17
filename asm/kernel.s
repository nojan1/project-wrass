    .org $8000
        ; unusable space on ROM, used by IO space
    .org $8100

    .include "include/constants.s"
    .include "include/lcd_8bit.s"

irq:
    rti

nmi:
    rti

reset:
    ldx $FF ;Set stackpointer to top of zero page
    txs



    .org $FFFA
    .word nmi
    .word reset
    .word irq