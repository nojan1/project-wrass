
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

test:
    .string "test"

reset:  
    ldx #$FF ;Set stackpointer to top of zero page
    txs

    .ifdef GRAPHIC_OUTPUT
    jsr gpu_display_init
    .else
    jsr lcd_display_init
    .endif

    jsr test_zp
    pha

    lda #0
    sta WRITE_POINTER
    sta READ_POINTER
    sta CURRENT_LINE
    sta CURRENT_COLUMN

; Zero page
    putstr_addr testing_zp_text
    pla
    beq .zp_ok
    jmp .error

.zp_ok:
    putstr_addr ok_text
    jsr newline

; Rom (1)
    putstr_addr testing_rom1_text
    jsr test_rom
    beq .rom_ok
    jmp .error

.rom_ok:
    putstr_addr ok_text
    jsr newline

; Ram1
    lda #$01
    sta MEM_HIGH
    lda #$80
    sta MEM_UPPER_BOUNDRY

    putstr_addr testing_ram1_text
    jsr test_mem
    beq .ram1_done
    jmp .error

.ram1_done:
    putstr_addr ok_text
    jsr newline

; Ram3
    lda #$9F
    sta MEM_HIGH
    lda #$BC
    sta MEM_UPPER_BOUNDRY

    putstr_addr testing_ram3_text
    jsr test_mem
    beq .ram3_done
    jmp .error

.ram3_done:
    putstr_addr ok_text
    jsr newline

; Ram2 (banking)
    putstr_addr testing_ram2_text
    
    ldx #0
.set_next_bank:
    txa ; We will use a for bank number
    inx ; Pre increment for next bank
    cpx #32
    beq .all_banks_set ; Oops we have already prepped all banks

    rol a
    rol a
    rol a ; Shift left 3 steps to move into bit 3..7 region which is the bank number
    sta MEM_CONTROL

    ldy #0
    sty $1
    
    lda #$80
.write_next_block 
    sta $2
    pha

    txa
    ldy #$FF
.write_next_byte
    sta ($1), y
    dey
    bne .write_next_byte

    pla
    clc
    adc #1
    cmp #$a0
    bne .write_next_block
    jmp .set_next_bank

.all_banks_set: ; Everything is setup.. restart and read data back out
    ldx #0
.read_next_bank:
    txa ; We will use a for bank number
    inx ; Pre increment for next bank
    cpx #32
    beq .ram2_done ; Oops we have already read all banks

    rol a
    rol a
    rol a ; Shift left 3 steps to move into bit 3..7 region which is the bank number
    sta MEM_CONTROL

    ldy #0
    sty $1
    
    lda #$80
.read_next_block 
    sta $2
    pha

    ldy #$FF
.read_next_byte    
; break check
    lda ($01), y
    sta $10
    cpx $10
    bne .ram2_error

    dey
    bne .read_next_byte 

    pla
    clc
    adc #1
    cmp #$a0
    bne .read_next_block
    jmp .read_next_bank 

.ram2_done:
    putstr_addr ok_text
    jsr newline
    
    jmp .done

.ram2_error:
    tya

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
    
    jmp *

.done:
    putstr_addr done_text
    jmp *

nmi:
irq:
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irq
