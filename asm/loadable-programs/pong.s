;; Constants
SCREEN_WIDTH_BYTES = 62
SCREEN_HEIGHT_BYTES = 32
SCREEN_WIDTH_CHARS = 40
SCREEN_HEIGHT_CHARS = 30

PADDLE_HEIGHT_CHARS = 8

PADDLE_L_X = 0
PADDLE_R_X = SCREEN_WIDTH_CHARS - 1

;; Variables
VAR_PADDLE_L_Y = ZP_USAGE_TOP + 1
VAR_PADDLE_R_Y = VAR_PADDLE_L_Y + 1

VAR_BALL_X = VAR_PADDLE_R_Y + 1
VAR_BALL_Y = VAR_BALL_X + 1

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

    lda #0 ; Blank square (all background)
    ldy #$10 ; White on black
    jsr sys_clear_screen

    

    rts