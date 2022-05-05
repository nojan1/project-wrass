Architecture
-------------

# Memory map

| Type              | Start | End   | Size      |
| ----------------- | ----- | ----- | --------- |
| RAM (1)           | $0000 | $7FFF | 32k       |
| RAM (2)           | $8000 | $9FFF | 8k        |
| IO (1) / RAM (3)  | $A000 | $A1FF | 512 bytes |
| IO (2) / RAM (4)  | $A200 | $A3FF | 512 bytes |
| RAM (5)           | $A400 | $BFFF | 7K        |
| ROM (1) / RAM (6) | $C000 | $CFFF | 8k        |
| ROM (2)           | $E000 | $FFFF | 8k        |

The different areas marked RAM 3-5 can be switched off by modifing the hardware register located at memory address $0000. It has the following composition:

| Bit | Description      |
| --- | ---------------- |
| 0   | Enable RAM (3)   |
| 1   | Enable RAM (4)   |
| 2   | Enable RAM (6)   |
| 3   |                  |
| 4   | Blinkenlight (0) |
| 5   | Blinkenlight (1) |
| 6   | Blinkenlight (2) |
| 7   | Blinkenlight (3) |

# IO

The IO space region is a 1k byte range that is divided up into 16 different IO devices. This yields a total of 16 IO select lines having access to 64 bytes of address space each. However only IO bank 1 is used by default, giving 8 lines of internal expansion. IO bank 2 is broken out to the user port on the side and will not be decoded,

## IO Line Allocation (1)


| Line | Device  | Lower Address | Upper Address |
| ---- | ------- | ------------- | ------------- |
| 0    | IO Card | $A000         | $A03F         |
| 1    | GPU     | $A040         | $A07F         |
| 2    | LCD     | $A080         | $A0BF         |
| 3    |         | $A0C0         | $A0FF         |
| 4    |         | $A100         | $A13F         |
| 5    |         | $A140         | $A17F         |
| 6    |         | $A180         | $A1BF         |
| 7    |         | $A1C0         | $A1FF         |

## IO Line Allocation (2)

IO lines for user expansion

| Line | Device | Lower Address | Upper Address |
| ---- | ------ | ------------- | ------------- |
| 8    |        | $A200         | $A23F         |
| 9    |        | $A240         | $A27F         |
| 10   |        | $A280         | $A2BF         |
| 11   |        | $A2C0         | $A2FF         |
| 12   |        | $A300         | $A33F         |
| 13   |        | $A340         | $A37F         |
| 14   |        | $A380         | $A3BF         |
| 15   |        | $A3C0         | $A3FF         |

# Reset sequence

During the reset sequence the latch chip controlling the $0000 register is reset to 0. Resulting in all extra RAM banks being switched off. 

Once the 6502 goes to its reset vector and control is handed over to the kernel it will modify it to enable RAM (4). If the user wants to use the external IO it is up to that user to switch off RAM (4) and handle anything that was stored there.

The kernel will also use the blinkenlights to indicate the startup sequence. 