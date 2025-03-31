LAST = ZP_USAGE_TOP + 1

    .include "setup.s"

    lda #$0
    sta IO_SYSTEM_VIA_DDRB

    jsr sys_newline
    putstr_addr start_text
    jsr sys_newline

read_next:
    lda IO_SYSTEM_VIA_PORTB
    cmp LAST
    beq read_next

    sta LAST

    jsr sys_puthex
    jsr sys_newline
    bra read_next
 
    rts

start_text:
    .string 'Reading "keyboard"'