;; Constants
SCREEN_WIDTH_BYTES = 62
SCREEN_HEIGHT_BYTES = 32
SCREEN_WIDTH_CHARS = 40
SCREEN_HEIGHT_CHARS = 30

SNAKE_BODY_CHAR = $80
FOOD_CHAR = 107
; FOOD_CHAR = 255 - 25

MOVE_RIGHT_DOWN = $1
MOVE_LEFT_UP = $FF

BODY_X = $7F00
BODY_Y = $7E00
FOOD_X = $7D00
FOOD_Y = $7C00

;; Variables
HEAD_INDEX = ZP_USAGE_TOP + 1
SNAKE_LENGTH = HEAD_INDEX + 1
LAST_GRAPHICS_CONTROL = SNAKE_LENGTH + 1
DIR_X = LAST_GRAPHICS_CONTROL + 1
DIR_Y = DIR_X + 1
R_SEED = DIR_Y + 1
SCORE = R_SEED + 1
SHAKE_SEQ = SCORE + 1
SLOWDOWN_TARGET = SHAKE_SEQ + 1

    .include "setup.s"

    ; Setup IRQ handling
    lda #<on_irq
    sta USER_IRQ

    lda #>on_irq
    sta USER_IRQ + 1

    ; Enable GPU frame IRQ
    lda #01
    sta GRAPHICS_CONTROL

    lda KEYCODE_RAW
    sta R_SEED

init_game:
    ; Initialize game logic
    stz SCORE

    lda #$6 
    sta SNAKE_LENGTH

    lda #$2
    sta HEAD_INDEX
    
    lda #$0
    sta DIR_Y
    lda #$1
    sta DIR_X

    lda #3
    sta SLOWDOWN_TARGET

    jsr place_food

    ;; Initial snake data
    lda #15
    sta BODY_X + 0
    lda #15
    sta BODY_Y + 0

    lda #16
    sta BODY_X + 1
    lda #15
    sta BODY_Y + 1

    lda #17
    sta BODY_X + 2
    lda #15
    sta BODY_Y + 2
    ;; end of initial snake data

    ldy SLOWDOWN_TARGET
loop:
    cli
    jsr wait_refresh
    sei

    phy

    ldy SHAKE_SEQ
    beq _no_shake
    
    dey
    sty SHAKE_SEQ

    lda shake_offset, y
    sta GRAPHICS_XOFFSET

_no_shake:
    jsr check_input

    lda #0
    ldy #(1 << 4 | 0)
    jsr sys_clear_screen

    ply
    dey
    bne _no_move
    jsr move_snake
    ldy SLOWDOWN_TARGET

_no_move:
    phy

    jsr draw_food
    jsr draw_snake
    jsr draw_score
    
    ply
    bra loop

check_input:
    lda KEYCODE_RAW
    beq _no_input

    cmp #$34
    bne _check_up

    inc SNAKE_LENGTH

_check_up: 
    ldx #0
    cmp #$75 ; Up
    bne _check_right
    stx DIR_X
    lda #MOVE_LEFT_UP
    sta DIR_Y
    bra _no_input

_check_right:
    cmp #$74 ; Right
    bne _check_down
    stx DIR_Y
    lda #MOVE_RIGHT_DOWN
    sta DIR_X
    bra _no_input

_check_down:
    cmp #$72 ; Down
    bne _check_left
    stx DIR_X
    lda #MOVE_RIGHT_DOWN
    sta DIR_Y
    bra _no_input

_check_left
    cmp #$6b ; Left
    bne _no_input
    stx DIR_Y
    lda #MOVE_LEFT_UP
    sta DIR_X

_no_input:
    rts

move_snake:
    ldy HEAD_INDEX

    lda BODY_X, y
    clc
    adc DIR_X
    cmp #40
    bcs game_over
    iny
    sta BODY_X, y
    dey

    lda BODY_Y, y
    clc
    adc DIR_Y
    cmp #30
    bcs game_over
    iny
    sta BODY_Y, y
    dey

    jsr check_food

    inc HEAD_INDEX

    rts

check_food:
    dey
    lda BODY_X, y
    cmp FOOD_X
    bne _check_food_done

    lda BODY_Y, y
    cmp FOOD_Y
    bne _check_food_done

    ; We are on the same position as the food
    inc SNAKE_LENGTH
    inc SCORE

    lda SCORE
    and #$7
    cmp #$7
    bne _no_speed_increase

    lda SLOWDOWN_TARGET
    cmp #1
    beq _no_speed_increase
    dec SLOWDOWN_TARGET

_no_speed_increase:
    lda #(shake_offset_end - shake_offset + 1)
    sta SHAKE_SEQ

place_food:
    jsr rand_8
    and #$1F
    sta FOOD_Y
    
    jsr rand_8
    and #$1F
    sta FOOD_X

_check_food_done:
    rts

game_over_text:
    .string "GAME OVER!"
press_r_test:
    .string "PRESS R TO TRY AGAIN"
game_over:
    jsr draw_score

    ldx #15
    ldy #14
    jsr set_xy
    putstr_addr game_over_text

    ldx #10
    ldy #15
    jsr set_xy
    putstr_addr press_r_test

_wait_for_reset:
    cli
    lda KEYCODE_RAW
    cmp #$2d ; R key
    bne _wait_for_reset
    sei
    jmp init_game

draw_score:
    ldx #0
    ldy #0
    jsr set_xy
    lda SCORE
    jsr sys_puthex
    rts

draw_snake:
    ldx SNAKE_LENGTH
    ldy HEAD_INDEX

_draw_next:
    phx
    ldx BODY_X, y
    phy
    lda BODY_Y, y    
    tay
    jsr set_xy
    lda #SNAKE_BODY_CHAR
    sta GRAPHICS_DATA

    ply
    plx

    dey
    dex
    bne _draw_next

    rts

draw_food:
    ldx FOOD_X
    ldy FOOD_Y
    jsr set_xy
    
    lda #FOOD_CHAR
    sta GRAPHICS_DATA
    
    jsr set_color_xy
    lda #$40
    sta GRAPHICS_DATA

    rts

wait_refresh:
    wai
    lda LAST_GRAPHICS_CONTROL
    and #$1 ; Was the IRQ bit set?
    beq wait_refresh

    rts

set_color_xy:
    pha
    
    ; Calculate HIGH
    ; HIGH = $0800 + (ROW >> 2)
    tya
    lsr
    lsr
    ora #$08
    sta GRAPHICS_ADDR_HIGH

    bra _set_xy_low

set_xy:
    pha
    
    ; Calculate HIGH
    ; HIGH = ROW >> 2
    tya
    lsr
    lsr
    sta GRAPHICS_ADDR_HIGH

_set_xy_low:
    ; Calculate LOW
    ; LOW = (ROW << 6) | COL
    stx VAR_8BIT_1
    tya
    .repeat 6
    asl
    .endr
    ora VAR_8BIT_1
    sta GRAPHICS_ADDR_LOW

    pla
    rts

on_irq:
    pha
    lda GRAPHICS_CONTROL
    sta LAST_GRAPHICS_CONTROL
    pla
    rti

shake_offset:
    .byte 0
    .byte 1
    .byte 0
    .byte 1
shake_offset_end:

    .include "include/rand.s"