    .include "setup.s"

    jsr sys_newline
    putstr_addr _welcome
    jsr sys_newline
    putstr_addr _parta_message

    ; Put 16 bit input address in PARAM_16_1
    lda #<_input
    sta PARAM_16_1
    lda #>_input
    sta PARAM_16_1 + 1

    lda #0
    sta TERM_16_1_LOW
    sta TERM_16_1_HIGH

_nextrow:
    ; Set up math variables
    lda #0
    sta TERM_16_2_LOW
    sta TERM_16_2_HIGH

    ldy #$FF
_nextchar:
    iny
    lda (PARAM_16_1), y
    cmp #$FF
    beq _print_result

    jsr sys_convert_hex
    cmp #0
    beq _nextchar ; Zero is not a valid
    cmp #10
    bcs _nextchar ; Above 9

    ; We got the first digit (10s place)
    pha
    asl
    asl
    asl

    plx
    stx TERM_16_2_LOW
    clc
    adc TERM_16_2_LOW
    clc
    adc TERM_16_2_LOW
    sta TERM_16_2_LOW

    jsr sys_add_16
    ; 10's place added to accumulator. Now let's find the second digit
    ; First find the end of the string

_keep_going_forward:
    iny
    lda (PARAM_16_1), y
    bne _keep_going_forward

    phy ; Push the end of string offset to the stack so we can use it later
_prevchar:
    dey
    lda (PARAM_16_1), y

    jsr sys_convert_hex
    cmp #0
    beq _prevchar ; Zero is not a valid
    cmp #10
    bcs _prevchar ; Above 9

    ; A now contains the one's place digit, add it to accumulator    
    sta TERM_16_2_LOW
    jsr sys_add_16

    ; Time to move pointer forward for the next line to be processed
    pla
    clc
    adc PARAM_16_1
    sta PARAM_16_1

    lda #0
    adc PARAM_16_1 + 1
    sta PARAM_16_1 + 1

    jmp _nextrow

_print_result:
    lda TERM_16_1_HIGH
    jsr sys_puthex
    lda TERM_16_1_LOW
    jsr sys_puthex

    jsr sys_newline

    rts

_welcome:
    .string "Advent Of Code - 2023, day 1"

_parta_message:
    .string "Part A: "

_input:
    .include "aoc-2023-day1-input.inc"

    ; .string "1abc2"
    ; .string "pqr3stu8vwx"
    ; .string "a1b2c3d4e5f"
    ; .string "treb7uchet"
    ; .db $FF