Architecture
-------------

# Memory map

| Type              | Start | End   | Size |
| ----------------- | ----- | ----- | ---- |
| RAM (1)           | $0000 | $7FFF | 32k  |
| RAM (2)           | $8000 | $9FFF | 8k   |
| IO (1) / RAM (3)  | $A000 | $AFFF | 4k   |
| IO (2) / RAM (4)  | $B000 | $BFFF | 4k   |
| ROM (1) / RAM (5) | $C000 | $CFFF | 8k   |
| ROM (2)           | $D000 | $FFFF | 8k   |

# IO

The IO space region is a 8k byte range that is divided up into 16 different IO devices. This yields a total of 16 IO select lines having access to 512 bytes of address space each.

## IO Line Allocation (1)


| Line | Device  | Lower Address | Upper Address |
| ---- | ------- | ------------- | ------------- |
| 0    | IO Card | $A000         | $A1FF         |
| 1    | GPU     | $A200         | $A3FF         |
| 2    | SOUND   | $A400         | $A5FF         |
| 3    |         | $A600         | $A7FF         |
| 4    |         | $A800         | $A9FF         |
| 5    |         | $AA00         | $ABFF         |
| 6    |         | $AC00         | $ADFF         |
| 7    |         | $AE00         | $AFFF         |

## IO Line Allocation (2)

IO lines for user expansion

| Line | Device | Lower Address | Upper Address |
| ---- | ------ | ------------- | ------------- |
| 8    |        | $B000         | $B1FF         |
| 9    |        | $B200         | $B3FF         |
| 10   |        | $B400         | $B5FF         |
| 11   |        | $B600         | $B7FF         |
| 12   |        | $B800         | $B9FF         |
| 13   |        | $BA00         | $BBFF         |
| 14   |        | $BC00         | $BDFF         |
| 15   |        | $BE00         | $BFFF         |

