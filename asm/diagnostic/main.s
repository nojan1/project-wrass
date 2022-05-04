ZP_FIRST_WRITE_FAIL = 1
ZP_LOOP_WRITE_FAIL = ZP_FIRST_WRITE_FAIL

MEM_CONTROL = $0
PARAM_16_1 = $3
CURRENT_LINE = PARAM_16_1 + 2
CURRENT_COLUMN = CURRENT_LINE +1
READ_POINTER = CURRENT_COLUMN + 1
WRITE_POINTER = READ_POINTER + 1

GRAPHICS_BASE = $A040
GRAPHICS_CONTROL = GRAPHICS_BASE
GRAPHICS_YOFFSET = GRAPHICS_CONTROL + 1
GRAPHICS_XOFFSET = GRAPHICS_YOFFSET + 1
GRAPHICS_INCREMENT = GRAPHICS_XOFFSET + 1
GRAPHICS_ADDR_LOW = GRAPHICS_INCREMENT + 1
GRAPHICS_ADDR_HIGH = GRAPHICS_ADDR_LOW + 1
GRAPHICS_DATA = GRAPHICS_ADDR_HIGH + 1

INPUT_BUFFER = $0100 ; Will not be used but is needed for the shared code

    .macro test_byte, target, errorlabel
    ldy #0
    lda #0  
    sta (\target),y
    lda (\target),y
    cmp #0
    bne \errorlabel
    lda #$FF  
    sta (\target),y
    lda (\target),y
    cmp #$FF
    bne \errorlabel
    lda #$AA 
    sta (\target),y
    lda (\target),y
    cmp #$AA
    bne \errorlabel
    .endmacro
 
    .macro putstr_addr, ptr
    lda #<\ptr
    sta PARAM_16_1
    lda #>\ptr
    sta PARAM_16_1 + 1
    jsr putstr
    .endmacro

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

    putstr_addr testing_zp_text
    pla
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

.done:
    jmp *

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq