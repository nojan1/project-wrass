
    .include "constants.s"
    .include "macro.s"

    .org $C000 ; Monitor / Basic area
    .db $0, $1, $2, $3, $4, $5

    .org $D000
    .db $0, $1, $2, $3, $4, $5

    .org $E000 ; Kernel area

    .include "../kernel/include/utils/hex_utils.s"
    .include "../kernel/include/io/io_generic.s"

    .ifdef GRAPHIC_OUTPUT
    .include "../kernel/include/io/graphic/graphic.s"
    .include "../kernel/include/io/graphic/io_graphic.s"
    .else
    .include "../kernel/include/io/lcd/lcd_8bit.s"
    .include "../kernel/include/io/lcd/io_lcd.s"
    .endif

    .include "strings.s"

    .include "zp.s"
    .include "memory.s"

reset:  
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    jsr test_zp
    pha

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER
    sta CURRENT_LINE
    sta CURRENT_COLUMN

    jsr display_init

; Zero page
    putstr_addr testing_zp_text
    pla
    bne .error

    putstr_addr ok_text
    jsr newline

; Rom (1)
    putstr_addr testing_rom1_text
    jsr test_rom
    bne .error

    putstr_addr ok_text
    jsr newline

; Ram1
    lda #$01
    sta MEM_HIGH
    lda #$80
    sta MEM_UPPER_BOUNDRY

    putstr_addr testing_ram1_text
    jsr test_mem
    bne .error

    putstr_addr ok_text
    jsr newline

; Ram5
    lda #$a3
    sta MEM_HIGH
    lda #$c0
    sta MEM_UPPER_BOUNDRY

    putstr_addr testing_ram5_text
    jsr test_mem
    bne .error

    putstr_addr ok_text
    jsr newline

    jmp .done

.error:
    pha
    putstr_addr err_text
    jsr newline
    putstr_addr error_text
    pla
    jsr puthex

    jsr newline
    putstr_addr last_memory_text
    lda MEM_HIGH
    jsr puthex
    lda MEM_LOW
    jsr puthex

.done:
    jmp *

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq