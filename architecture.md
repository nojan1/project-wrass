Architecture
-------------

# Memory map

| Type                | Start | End   | Size |
| ------------------- | ----- | ----- | ---- |
| RAM (1)             | $0000 | $7FFF | 32k  |
| RAM (2)             | $8000 | $9FFF | 8k   |
| IO                  | $A000 | $BFFF | 8k   |
| ROM                 | $C000 | $FFFF | 16k  |
| ------------------- | ----  | ----- | ---  |
| Screen (Write only) | $C000 | ???   | ??   |

# IO

The IO space region is a 8k byte range that is divided up into 16 different IO devices. This yields a total of 16 IO select lines having access to 512 bytes of address space each.

## IO Line Allocation

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
| 8    |         | $B000         | $B1FF         |
| 9    |         | $B200         | $B3FF         |
| 10   |         | $B400         | $B5FF         |
| 11   |         | $B600         | $B7FF         |
| 12   |         | $B800         | $B9FF         |
| 13   |         | $BA00         | $BBFF         |
| 14   |         | $BC00         | $BDFF         |
| 15   |         | $BE00         | $BFFF         |

# Screen

The framebuffer, tilemap and color attributes are stored in seperate RAM. It shares address space with ROM however since writing to the ROM is a no-op this action is repurposed to write to screen RAM. Note that that does make the Screen RAM write-only!

To access information about Screen stuff the IO space is used.

## Screen RAM Map (Character mode)

| Type             | Lower Address | Upper Address |
| ---------------- | ------------- | ------------- |
| Framebuffer      | $C000         | $D2C0         |
| Color Attributes | $D2C1         | $E581         |
| Tilemap          | $E582         | $ED81         |
| Colors           | $ED82         | $EE02         |

### Framebuffer format

The framebuffer is composed of 80 * 60 bytes confirming to 80 columns and 60 rows layed out in row order. Each byte in the buffer matches a single tile in the tilemap. 

### Color Attributes

The color attributes are layed out in the same format as the framebuffer with the difference that each byte instead describes the color for the rendered tile. The lower 4 bits matches to 16 different colors for the background and the top 4 is the color for the foreground.

### Tilemap format

The tilemap is composed of 8 bytes per tile, coresponding to 8 rows. When converting to pixels it is simply 0 == pixel off, 1 == pixel on.

The example below would make a crappy 'A' when rendered.

```
byte 
 0:  0 0 0 0 0 0 0 0
 1:  0 0 0 1 1 0 0 0
 2:  0 0 1 1 1 1 0 0
 3:  0 1 1 0 0 1 1 0
 4:  0 1 1 0 0 1 1 0
 5:  0 1 1 1 1 1 1 0
 6:  0 1 1 1 1 1 1 0
 7:  0 1 1 0 0 1 1 0
```

## Screen RAM Map (Bitmap mode)

| Type               | Lower Address | Upper Address |
| ------------------ | ------------- | ------------- |
| Bitmap data format | $C000         | $E580         |
| Tilemap            | $E582         | $ED81         |
| Colors             | $ED82         | $EE02         |

### Bitmap data

The bitmap data is encoded in a 2bp and the screen resolution is reduced to 320x240.
The available colors are the first 4 in the color map.

Example:
```
  00_01_10_11 
```
Would translate to a row of 4 pixels as such:
```
<color 0><color 1><color 2><color 3>
```

## Colors format

The colors are a collection of 16 bytes each describing one of the 16 available colors. The format is: `xxRRGGBB`. Meaning 2 bit for each color and the 2 top bits are ignored.