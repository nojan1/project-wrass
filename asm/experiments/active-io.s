
   
    .org $C000 ; Monitor / Basic area


    .org $E000 ; Kernel area
top:
    lda #$EA
    sta $A000
    nop
    nop
    nop
    nop
    nop

    lda #$aa
    sta $A041
    nop
    nop
    nop
    nop
    nop

    jmp top

; sleep:
;     ldx #0
; .keep_sleeping:
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     nop
;     inx
;     beq .done
;     jmp .keep_sleeping
    
; .done:
; ; brk end of sleep
;     rts

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word top
    .word irq