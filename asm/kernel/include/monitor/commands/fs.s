; Implementation for the ls command
ls_command_implementation:
    nop
    jsr newline
    jsr list_current_directory
    jmp _command_execution_complete

; Implementation for the cd command
cd_command_implementation:
    nop

    jsr newline

    stz ERROR
    jsr find_directory_entry_in_current_directory
    jsr check_and_print_error
    bcs _cd_command_implementation_done

    ; Set the current directory cluster to what find_directory_entry_in_current_directory left
    ldy #$14 + 1
    lda (TERM_16_1_LOW), y
    sta CURRENT_DIRECTORY_CLUSTER + 3
    ldy #$14 + 0
    sta CURRENT_DIRECTORY_CLUSTER + 2
    ldy #$1A + 1
    lda (TERM_16_1_LOW), y
    sta CURRENT_DIRECTORY_CLUSTER + 1
    ldy #$1A + 0
    lda (TERM_16_1_LOW), y
    sta CURRENT_DIRECTORY_CLUSTER + 0

_cd_command_implementation_done:
    jmp _command_execution_complete

; Implementation for the cat command
cat_command_implementation:
    nop

    jsr newline
    jsr open_file
    jsr check_and_print_error
    bcs .done

.read_next_block:
    jsr read_file
    bcs .done

    cpx #0
    beq .done

    ldy #0
.print_next:
    lda (PARAM_16_1), y
    cmp #10
    beq .print_newline
    jsr putc
    bra .char_print_done
.print_newline:
    jsr newline
.char_print_done:
    iny
    dex
    bne .print_next
    bra .read_next_block

.done:    
    jmp _command_execution_complete
;     stz ERROR
;     jsr find_file_entry_in_current_directory
;     jsr check_and_print_error
;     bcs _cat_command_implementation_done

;     jsr set_current_cluster_from_entry


;     ldy #0
;     ldx #0
; _cat_command_implementation_read_next_sector:
;     lda #<SD_BUFFER
;     sta PARAM_16_1
;     lda #>SD_BUFFER
;     sta PARAM_16_1 + 1

;     jsr read_cluster

; _cat_command_implementation_inner_loop:
;     lda (PARAM_16_1), y
;     cmp #10
;     beq _cat_command_implementation_newline
;     jsr putc
;     bra _cat_command_next_byte

; _cat_command_implementation_newline:
;     jsr newline

; _cat_command_next_byte:
;     ; Subtract 1 byte from the size... very compact not

;     sec
;     sbc #1
;     sta TERM_32_2_1
;     lda TERM_32_2_2
;     sbc #0
;     sta TERM_32_2_2
;     lda TERM_32_2_3
;     sbc #0
;     sta TERM_32_2_3
;     lda TERM_32_2_4
;     sbc #0
;     sta TERM_32_2_4
    
;     ; Check if the size reached 0
;     lda TERM_32_2_1
;     ora TERM_32_2_2
;     ora TERM_32_2_3
;     ora TERM_32_2_4
;     beq _cat_command_implementation_done

;     iny
;     bne _cat_command_implementation_inner_loop

;     ; Will only read 256 bytes for now... we need to something cool here later

; _cat_command_implementation_done:
;     jmp _command_execution_complete