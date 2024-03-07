jump_command_implementation:
    nop

    ; Put the return point on the stack
    lda #>(_command_execution_complete - 1)
    pha
    lda #<(_command_execution_complete - 1)
    pha

    ; Put the user provided address as return address on stack
    lda PARAM_16_2        ; Load low part of address
    sec
    sbc #1                ; Subtract 1 to account for rts incrementing PC
    tay                   ; Move to Y 
    lda PARAM_16_2 + 1    ; Load high part
    sbc #0                ; Subtract if carry set
    pha                   ; Push high part on stack
    phy                   ; Push low part on stack

    ; "Return" to the user provided address
    rts