    .include "setup.s"

    jsr sys_newline
    putstr_addr the_string
    rts

the_string:
    .string "Helloy world!"
