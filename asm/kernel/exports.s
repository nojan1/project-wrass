    .macro ifndef_nop, define, ptr
    .ifndef \define
    jmp \ptr
    .else
    nop
    nop
    rts
    .endif
    .endmacro



; IO Generic
sys_getc:
    jmp getc

sys_putc:
    jmp putc

sys_putstr:
    jmp putstr

sys_newline:
    jmp newline

sys_ereasec:
    jmp ereasec

; UART
sys_uart_sendbyte:
    ifndef_nop NO_UART, uart_sendbyte
; GPU
sys_copy_sprite:
    ifndef_nop NO_GPU, copy_sprite

sys_clear_screen:
    ifndef_nop NO_GPU, clear_screen

sys_goto_tilemap_x_y:
    ifndef_nop NO_GPU, goto_tilemap_x_y

sys_goto_colorattribute_x_y:
    ifndef_nop NO_GPU, goto_colorattribute_x_y

; SPI
sys_spi_set_device:
    jmp spi_set_device

sys_spi_transcieve:
    jmp spi_transcieve

sys_spi_read:
    jmp spi_read

sys_spi_clk:
    jmp spi_clk

; Math
sys_add_16:
    jmp add_16

sys_sub_16:
    jmp sub_16

sys_mul_16:
    jmp mul_16

sys_add_32:
    jmp add_32

sys_sub_32:
    jmp sub_32

; HEX
sys_puthex:
    jmp puthex

sys_putchex:
    jmp putchex

sys_convert_hex:
    jmp convert_hex

; Strings
sys_str_startswith:
    jmp str_startswith

sys_str_readhex:
    jmp str_readhex

sys_str_readhexchar:
    jmp str_readhexchar
