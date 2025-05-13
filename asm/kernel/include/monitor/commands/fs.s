; Implementation for the ls command
ls_command_implementation:
    nop
    jsr newline

    ; Make sure the SD card is initialized
    lda SD_CARD_STATUS
    cmp #SD_CARD_INITIALIZED
    beq .no_error

    lda #ERROR_SD_CARD_NOT_INITIALIZED
    sta ERROR 
    jsr check_and_print_error
    bra .on_error

.no_error:
    jsr list_current_directory
.on_error:
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