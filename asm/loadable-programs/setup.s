sys_add_16 = $E024
sys_add_32 = $E02D
sys_clear_screen = $E015
sys_convert_hex = $E039
sys_copy_sprite = $E012
sys_ereasec = $E00C
sys_getc = $E000
sys_goto_colorattribute_x_y = $E01B
sys_goto_tilemap_x_y = $E018
sys_mul_16 = $E02A
sys_newline = $E009
sys_putc = $E003
sys_putchex = $E036
sys_puthex = $E033
sys_putstr = $E006
sys_spi_set_device = $E01E
sys_spi_transcieve = $E021
sys_str_readhex = $E03F
sys_str_readhexchar = $E042
sys_str_startswith = $E03C
sys_sub_16 = $E027
sys_sub_32 = $E030
sys_uart_sendbyte = $E00F

putstr=sys_putstr ; Used in macro definition
    
    .include "../kernel/include/constants.s"
    .include "../kernel/include/macros.s"
    .org $0400


