Architecture
-------------

# Memory map

| Type              | Start | End   | Size      |
| ----------------- | ----- | ----- | --------- |
| RAM (1)           | $0000 | $7FFF | 32k       |
| RAM (2)           | $8000 | $9FFF | 8k        |
| RAM (3)           | $A000 | $BBFF | 7K        |
| IO (1)            | $BC00 | $BDFF | 512 bytes |
| IO (2) / RAM (4)  | $BE00 | $BFFF | 512 bytes |
| ROM (1) / RAM (5) | $C000 | $DFFF | 8k        |
| ROM (2) / RAM (6) | $E000 | $FFFF | 8k        |

The different areas marked RAM 3-5 can be switched off by modifying the hardware register located at memory address $0000. It has the following composition:

| Bit | Description          |
| --- | -------------------- |
| 0   | Enable RAM (4)       |
| 1   | Enable RAM (5)       |
| 2   | Enable RAM (6)       |
| 3   | RAM (2) bank (bit 0) |
| 4   | RAM (2) bank (bit 1) |
| 5   | RAM (2) bank (bit 2) |
| 6   | RAM (2) bank (bit 3) |
| 7   | RAM (2) bank (bit 4) |

# IO

The IO space region is a 1k byte range that is divided up into 16 different IO devices. This yields a total of 16 IO select lines having access to 64 bytes of address space each. However only IO bank 1 is used by default, giving 8 lines of internal expansion. IO bank 2 is broken out to the user port on the side and will not be decoded,

## IO Line Allocation (1)


| Line | Device  | Lower Address | Upper Address |
| ---- | ------- | ------------- | ------------- |
| 0    | IO Card | $BC00         | $BC3F         |
| 1    | GPU     | $BC40         | $BC7F         |
| 2    | LCD     | $BC80         | $BCBF         |
| 3    |         | $BCC0         | $BCFF         |
| 4    |         | $BD00         | $BD3F         |
| 5    |         | $BD40         | $BD7F         |
| 6    |         | $BD80         | $BDBF         |
| 7    |         | $BDC0         | $BDFF         |

## IO Line Allocation (2)

IO lines for user expansion

| Line | Device | Lower Address | Upper Address |
| ---- | ------ | ------------- | ------------- |
| 8    |        | $BE00         | $BE3F         |
| 9    |        | $BE40         | $BE7F         |
| 10   |        | $BE80         | $BEBF         |
| 11   |        | $BEC0         | $BEFF         |
| 12   |        | $BF00         | $BF3F         |
| 13   |        | $BF40         | $BF7F         |
| 14   |        | $BF80         | $BFBF         |
| 15   |        | $BFC0         | $BFFF         |

# Reset sequence

During the reset sequence the latch chip controlling the $0000 register is reset to 0. Resulting in all extra RAM banks being switched off. 

Once the 6502 goes to its reset vector and control is handed over to the kernel it will modify it to enable RAM (5). If the user wants to use the external IO it is up to that user to switch off RAM (5) and handle anything that was stored there.