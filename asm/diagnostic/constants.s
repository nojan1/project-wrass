ZP_FIRST_WRITE_FAIL = 1
ZP_LOOP_WRITE_FAIL = ZP_FIRST_WRITE_FAIL + 1
RAM_LOOP_WRITE_FAIL = ZP_LOOP_WRITE_FAIL + 1
ROM_1_FIRST_DATA_FAIL = RAM_LOOP_WRITE_FAIL + 1
ROM_1_SECOND_DATA_FAIL = ROM_1_FIRST_DATA_FAIL + 1

MEM_CONTROL = $0
MEM_LOW = MEM_CONTROL + 1
MEM_HIGH = MEM_LOW + 1
MEM_UPPER_BOUNDRY = MEM_HIGH + 1
PARAM_16_1 = MEM_UPPER_BOUNDRY + 1
CURRENT_LINE = PARAM_16_1 + 2
CURRENT_COLUMN = CURRENT_LINE +1
READ_POINTER = CURRENT_COLUMN + 1
WRITE_POINTER = READ_POINTER + 1

GRAPHICS_BASE = $BC40
GRAPHICS_CONTROL = GRAPHICS_BASE
GRAPHICS_YOFFSET = GRAPHICS_CONTROL + 1
GRAPHICS_XOFFSET = GRAPHICS_YOFFSET + 1
GRAPHICS_INCREMENT = GRAPHICS_XOFFSET + 1
GRAPHICS_ADDR_LOW = GRAPHICS_INCREMENT + 1
GRAPHICS_ADDR_HIGH = GRAPHICS_ADDR_LOW + 1
GRAPHICS_DATA = GRAPHICS_ADDR_HIGH + 1

LCD_PORTB = $BC80
LCD_PORTA = LCD_PORTB + 1
LCD_DDRB = LCD_PORTA + 1
LCD_DDRA = LCD_DDRB + 1

INPUT_BUFFER = $0200 ; Will not be used but is needed for the shared code

UART_BASE = $BCC0
UART_TRANSMIT = UART_BASE
UART_RECIEVE = UART_TRANSMIT + 1
UART_STATUS = UART_RECIEVE + 1
