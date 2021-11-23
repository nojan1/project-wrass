Architecture
-------------

# Memory map

| Type                | Start | End   |
| ------------------- | ----- | ----- |
| RAM                 | $0000 | $7FFF |
| IO                  | $8000 | $80FF |
| ROM                 | $8100 | $FFFF |
| ------------------- | ----  | ----- |
| Screen (Write only) | $C000 | ???   |

# IO

The IO space region is a 256 byte range that is divided up into 8 different IO devices. This yields a total of 8 IO select lines having access to 32 bytes of address space each.

## IO Line Allocation

| Line | Device  | Lower Address | Upper Address |
| ---- | ------- | ------------- | ------------- |
| 0    | IO Card | $8000         | $801F         |
| 1    | GPU     | $8020         | $803F         |
| 2    | Sound   | $8040         | $805F         |
| 3    |         | $8060         | $807F         |
| 4    |         | $8080         | $809F         |
| 5    |         | $80A0         | $80BF         |
| 6    |         | $80C0         | $80DF         |
| 7    |         | $80E0         | $80FF         |

# Screen

The framebuffer, tilemap and color attributes are stored in seperate RAM. It shares address space with ROM however since writing to the ROM is a no-op this action is repurposed to write to screen RAM. Note that that does make the Screen RAM write-only!

To access information about Screen stuff the IO space is used.

## Screen RAM Map

| Type             | Lower Address | Upper Address |
| ---------------- | ------------- | ------------- |
| Framebuffer      | $C000         | $D2C0         |
| Color Attributes | $D2C1         | $E581         |
| Tilemap          | $E582         | $ED81         |
| Colors           | $ED82         | $EE02         |

## Framebuffer format

The framebuffer is composed of 80 * 60 bytes confirming to 80 columns and 60 rows layed out in row order. Each byte in the buffer matches a single tile in the tilemap. 

## Color Attributes

The color attributes are layed out in the same format as the framebuffer with the difference that each byte instead describes the color for the rendered tile. The lower 4 bits matches to 16 different colors for the background and the top 4 is the color for the foreground.

## Tilemap format

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

## Colors format

The colors are a collection of 16 bytes each describing one of the 16 available colors. The format is: `xxRRGGBB`. Meaning 2 bit for each color and the 2 top bits are ignored.