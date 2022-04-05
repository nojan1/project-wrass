; puts the number stored in A
puthex:
    pha 
    and #0b11110000
    lsr
    lsr
    lsr
    lsr ; A now contains the top 4 bits in the bottom position
    jsr putchex
    pla
    pha 
    and #0b00001111
    jsr putchex
    pla
    rts

; convert the hex number (0-15) stored in A to ascii and calls putc
putchex:
    cmp #9
    bcs .above_9

    clc
    adc #$30
    jsr putc
    rts 

.above_9:
    clc
    adc #($41 - $A)
    jsr putc
    rts


