;; Constants
SCREEN_WIDTH_BYTES = 62
SCREEN_HEIGHT_BYTES = 32
SCREEN_WIDTH_CHARS = 40
SCREEN_HEIGHT_CHARS = 30

PADDLE_HEIGHT_CHARS = 8

PADDLE_L_X = 0
PADDLE_R_X = SCREEN_WIDTH_CHARS - 1

EMPTY_CHAR = 0
BALL_CHAR = 105

;; Variables
VAR_PADDLE_L_Y = ZP_USAGE_TOP + 1
VAR_PADDLE_R_Y = VAR_PADDLE_L_Y + 1

VAR_BALL_X = VAR_PADDLE_R_Y + 1
VAR_BALL_Y = VAR_BALL_X + 1
VAR_BALL_MOV_X = VAR_BALL_Y + 1
VAR_BALL_MOV_Y = VAR_BALL_MOV_X + 1

    .include "setup.s"

    ; Reset scroll 
    lda #0
    sta GRAPHICS_YOFFSET
    sta GRAPHICS_XOFFSET

    ; Set paddle starting position
    lda #((SCREEN_HEIGHT_CHARS / 2) - (PADDLE_HEIGHT_CHARS / 2))
    sta VAR_PADDLE_L_Y
    sta VAR_PADDLE_R_Y

    ; Set ball starting position
    lda #(SCREEN_WIDTH_CHARS / 2)
    sta VAR_BALL_X
    lda #(SCREEN_HEIGHT_CHARS / 2)
    sta VAR_BALL_Y

    lda #1
    sta VAR_BALL_MOV_X
    sta VAR_BALL_MOV_Y

    jsr redraw_screen

.next_frame:
    jsr ball_move

    jsr wait_frame
    jmp .next_frame

    rts

ball_move:
    ldx VAR_BALL_X
    ldy VAR_BALL_Y
    lda #EMPTY_CHAR
    jsr set_char_at_pos 

    txa
    clc
    adc VAR_BALL_MOV_X
    sta VAR_BALL_X
    tax

    tya
    clc
    adc VAR_BALL_MOV_Y
    sta VAR_BALL_Y
    tay 

    lda VAR_BALL_Y
    beq .invert_ball_y_direction
    cpy #SCREEN_HEIGHT_CHARS
    beq .invert_ball_y_direction
    
    lda VAR_BALL_X
    beq .invert_ball_x_direction
    cpx #SCREEN_WIDTH_CHARS
    beq .invert_ball_x_direction

    jmp .draw_ball

.invert_ball_y_direction:
    lda VAR_BALL_MOV_Y
    bmi .ball_y_movement_was_negative
    lda #$FF
    jmp .store_ball_y_movement
.ball_y_movement_was_negative:
    lda #1
.store_ball_y_movement:
    sta VAR_BALL_MOV_Y

    jmp .draw_ball

.invert_ball_x_direction:
    lda VAR_BALL_MOV_X
    bmi .ball_x_movement_was_negative
    lda #$FF
    jmp .store_ball_x_movement
.ball_x_movement_was_negative:
    lda #1
.store_ball_x_movement:
    sta VAR_BALL_MOV_X

    jmp .draw_ball

.draw_ball:
    lda #BALL_CHAR
    jsr set_char_at_pos 

    rts

.ball_y_zero:


redraw_screen:
    lda #EMPTY_CHAR
    ldy #$10 ; White on black
    jsr sys_clear_screen

    ldx VAR_BALL_X
    ldy VAR_BALL_Y
    lda #BALL_CHAR
    jsr set_char_at_pos

    ldx #PADDLE_L_X
    ldy VAR_PADDLE_L_Y
    jsr draw_paddle

    ldx #PADDLE_R_X
    ldy VAR_PADDLE_R_Y
    jsr draw_paddle

    rts

; Draws a single pad, expect Y and X position in coresponding registries
draw_paddle:
    pha
    lda #128
    .repeat PADDLE_HEIGHT_CHARS
    jsr set_char_at_pos
    iny
    .endr

    pla
    rts

; Puts the character in A onto character space specified in X, Y
set_char_at_pos:
    jsr sys_goto_tilemap_x_y
    sta GRAPHICS_DATA

    rts

wait_frame:
    phy
    phx

    ldy #$FF
.keep_waiting_1:
    ldx #$2
.keep_waiting_2:
    .repeat 10
    nop
    .endr
    dex
    bne .keep_waiting_2
    dey
    bne .keep_waiting_1

    plx
    ply
    rts