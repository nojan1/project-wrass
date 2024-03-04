sys_add_16 = $EAC7
sys_add_32 = $EAD0
sys_convert_hex = $EADC
sys_copy_sprite = $EAB8
sys_ereasec = $EAB2
sys_getc = $EAA6
sys_mul_16 = $EACD
sys_newline = $EAAF
sys_putc = $EAA9
sys_putchex = $EAD9
sys_puthex = $EAD6
sys_putstr = $EAAC
sys_spi_clk = $EAC4
sys_spi_read = $EAC1
sys_spi_set_device = $EABB
sys_spi_transcieve = $EABE
sys_str_readhex = $EAE2
sys_str_readhexchar = $EAE5
sys_str_startswith = $EADF
sys_sub_16 = $EACA
sys_sub_32 = $EAD3
sys_uart_sendbyte = $EAB5    
    
putstr=sys_putstr
    
    .include "../kernel/include/constants.s"
    .include "../kernel/include/macros.s"
    .org $0400