SD_CARD_INIT_FAILED = 1
SD_CARD_BLOCKSET_FAILED = SD_CARD_INIT_FAILED + 2
SD_READ_TIMEOUT = SD_CARD_BLOCKSET_FAILED + 2
SD_READ_ERROR = SD_READ_TIMEOUT + 2
INVALID_MBR = SD_READ_ERROR + 2
NO_VALID_PARTITION = INVALID_MBR + 2
UNSUPPORTED_NUMBER_OF_FATS = NO_VALID_PARTITION + 2
UART_RECIEVE_BUFFER_OVERFLOW = UNSUPPORTED_NUMBER_OF_FATS + 2
SD_ILLEGAL_COMMAND = UART_RECIEVE_BUFFER_OVERFLOW + 2
FILE_NOT_FOUND = SD_ILLEGAL_COMMAND + 2
ERROR_SD_CARD_NOT_INITIALIZED = FILE_NOT_FOUND + 2