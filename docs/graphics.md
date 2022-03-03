# Graphics

The graphics unit is a separete IO device hooked up to one of the IO lines in the IO address space.

## Registers

| Address | Register name           | Description                                                                                                                 |
| ------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| $0000   | Control                 | Uset to control the overall operation of the graphics unit                                                                  |
| $0001   | Y-Offset                | Global screen offset for render, bit 6 controls positive or negative offset, bit 7 is ignored                               |
| $0002   | X-Offset                | Global screen offset for render, bit 6 controls positive or negative offset, bit 7 is ignored                               |
| $0003   | Increment               | After a memory operation using the Read/Write register the address will increment/decrement (control by bit 7) by this much |
| $0004   | Internal address (Low)  | When doing memory access this is the LOW part of the 16 bit address                                                         |
| $0005   | Internal address (High) | When doing memory access this is the HIGH part of the 16 bit address                                                        |
| $0006   | Read/Write              | Performing a write to the is register will write that value to the memory address of ($0004)                                | ($0005). Performing a read will instead return the value at that location |

# Screen

The framebuffer, tilemap and color attributes are stored in seperate RAM. Writes and reads from this area is done using the registers described above

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