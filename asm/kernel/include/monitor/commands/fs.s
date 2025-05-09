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

; Implementation for the cat command, not finished and will barely work for small (<256) text files
cat_command_implementation:
    nop

    jsr newline

    stz ERROR
    jsr find_file_entry_in_current_directory
    jsr check_and_print_error
    bcs _cat_command_implementation_done

    jsr set_current_cluster_from_entry


    ldy #0
    ldx #0
_cat_command_implementation_read_next_sector:
    lda #<SD_BUFFER
    sta PARAM_16_1
    lda #>SD_BUFFER
    sta PARAM_16_1 + 1

    jsr read_cluster

_cat_command_implementation_inner_loop:
    lda (PARAM_16_1), y
    jsr putc

    ; Subtract 1 byte from the size... very compact not
    lda #1
    sec
    sbc TERM_32_1_1
    sta TERM_32_1_1
    lda #0
    sbc TERM_32_1_2
    sta TERM_32_1_2
    lda #0
    sbc TERM_32_1_3
    sta TERM_32_1_3
    lda #0
    sbc TERM_32_1_4
    sta TERM_32_1_4
    
    ; Check if the size reached 0
    lda TERM_32_1_1
    ora TERM_32_1_2
    ora TERM_32_1_3
    ora TERM_32_1_4
    beq _cat_command_implementation_done

    iny
    bne _cat_command_implementation_inner_loop

    ; Will only read 256 bytes for now... we need to something cool here later

_cat_command_implementation_done:
    jmp _command_execution_complete