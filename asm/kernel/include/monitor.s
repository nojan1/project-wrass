commands:
    db "d" ; dump <addr> <count>
    db 2 ; num parameters


; Enter monitor REPL
monitor_loop:
    lda #">"
    jsr putc
    
    lda #" "
    jsr putc

    ldx #0
monitor_loop_read:
    jsr getc
    beq monitor_loop_read

    cmp #13 ; Was enter pressed?
    beq monitor_loop_command_entered

    jsr putc
    sta COMMAND_BUFFER, x
    inx

    jmp monitor_loop_read

monitor_loop_command_entered:
    jmp monitor_loop
