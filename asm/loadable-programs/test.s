putstr=$E21B
    .include "setup.s"

    putstr_addr the_string
    rts

the_string:
    .string "Helloy world!"
