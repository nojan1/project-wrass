    .org $C000
    
    .include "../kernel/include/constants.s"

UART_WRITE = $BCC0

message:
    .string "Hello, world"

reset:  
    ldx #$FF ;Set stackpointer to top of zero page
    txs

loop:
    ldx #0
keep_printing:
    lda message, x
    beq done_printing

    sta UART_WRITE
    inx
    jmp keep_printing

done_printing:
    ldx #0
keep_waiting:
    inx
    bne keep_waiting

    jmp loop

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq
