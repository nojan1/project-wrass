const fs = require("fs");

const rawTileset = [
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0000 (nul)
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0001
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0002
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0003
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0004
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0005
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0006
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0007
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0008
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0009
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000A
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000B
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000C
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000D
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000E
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+000F
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0010
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0011
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0012
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0013
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0014
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0015
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0016
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0017
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0018
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0019
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001A
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001B
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001C
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001D
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001E
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+001F
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0020 (space)
  0x18,
  0x3c,
  0x3c,
  0x18,
  0x18,
  0x00,
  0x18,
  0x00, // U+0021 (!)
  0x36,
  0x36,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0022 (")
  0x36,
  0x36,
  0x7f,
  0x36,
  0x7f,
  0x36,
  0x36,
  0x00, // U+0023 (#)
  0x0c,
  0x3e,
  0x03,
  0x1e,
  0x30,
  0x1f,
  0x0c,
  0x00, // U+0024 ($)
  0x00,
  0x63,
  0x33,
  0x18,
  0x0c,
  0x66,
  0x63,
  0x00, // U+0025 (%)
  0x1c,
  0x36,
  0x1c,
  0x6e,
  0x3b,
  0x33,
  0x6e,
  0x00, // U+0026 (&)
  0x06,
  0x06,
  0x03,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0027 (')
  0x18,
  0x0c,
  0x06,
  0x06,
  0x06,
  0x0c,
  0x18,
  0x00, // U+0028 (()
  0x06,
  0x0c,
  0x18,
  0x18,
  0x18,
  0x0c,
  0x06,
  0x00, // U+0029 ())
  0x00,
  0x66,
  0x3c,
  0xff,
  0x3c,
  0x66,
  0x00,
  0x00, // U+002A (*)
  0x00,
  0x0c,
  0x0c,
  0x3f,
  0x0c,
  0x0c,
  0x00,
  0x00, // U+002B (+)
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x0c,
  0x0c,
  0x06, // U+002C (,)
  0x00,
  0x00,
  0x00,
  0x3f,
  0x00,
  0x00,
  0x00,
  0x00, // U+002D (-)
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x0c,
  0x0c,
  0x00, // U+002E (.)
  0x60,
  0x30,
  0x18,
  0x0c,
  0x06,
  0x03,
  0x01,
  0x00, // U+002F (/)
  0x3e,
  0x63,
  0x73,
  0x7b,
  0x6f,
  0x67,
  0x3e,
  0x00, // U+0030 (0)
  0x0c,
  0x0e,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x3f,
  0x00, // U+0031 (1)
  0x1e,
  0x33,
  0x30,
  0x1c,
  0x06,
  0x33,
  0x3f,
  0x00, // U+0032 (2)
  0x1e,
  0x33,
  0x30,
  0x1c,
  0x30,
  0x33,
  0x1e,
  0x00, // U+0033 (3)
  0x38,
  0x3c,
  0x36,
  0x33,
  0x7f,
  0x30,
  0x78,
  0x00, // U+0034 (4)
  0x3f,
  0x03,
  0x1f,
  0x30,
  0x30,
  0x33,
  0x1e,
  0x00, // U+0035 (5)
  0x1c,
  0x06,
  0x03,
  0x1f,
  0x33,
  0x33,
  0x1e,
  0x00, // U+0036 (6)
  0x3f,
  0x33,
  0x30,
  0x18,
  0x0c,
  0x0c,
  0x0c,
  0x00, // U+0037 (7)
  0x1e,
  0x33,
  0x33,
  0x1e,
  0x33,
  0x33,
  0x1e,
  0x00, // U+0038 (8)
  0x1e,
  0x33,
  0x33,
  0x3e,
  0x30,
  0x18,
  0x0e,
  0x00, // U+0039 (9)
  0x00,
  0x0c,
  0x0c,
  0x00,
  0x00,
  0x0c,
  0x0c,
  0x00, // U+003A (:)
  0x00,
  0x0c,
  0x0c,
  0x00,
  0x00,
  0x0c,
  0x0c,
  0x06, // U+003B (;)
  0x18,
  0x0c,
  0x06,
  0x03,
  0x06,
  0x0c,
  0x18,
  0x00, // U+003C (<)
  0x00,
  0x00,
  0x3f,
  0x00,
  0x00,
  0x3f,
  0x00,
  0x00, // U+003D (=)
  0x06,
  0x0c,
  0x18,
  0x30,
  0x18,
  0x0c,
  0x06,
  0x00, // U+003E (>)
  0x1e,
  0x33,
  0x30,
  0x18,
  0x0c,
  0x00,
  0x0c,
  0x00, // U+003F (?)
  0x3e,
  0x63,
  0x7b,
  0x7b,
  0x7b,
  0x03,
  0x1e,
  0x00, // U+0040 (@)
  0x0c,
  0x1e,
  0x33,
  0x33,
  0x3f,
  0x33,
  0x33,
  0x00, // U+0041 (A)
  0x3f,
  0x66,
  0x66,
  0x3e,
  0x66,
  0x66,
  0x3f,
  0x00, // U+0042 (B)
  0x3c,
  0x66,
  0x03,
  0x03,
  0x03,
  0x66,
  0x3c,
  0x00, // U+0043 (C)
  0x1f,
  0x36,
  0x66,
  0x66,
  0x66,
  0x36,
  0x1f,
  0x00, // U+0044 (D)
  0x7f,
  0x46,
  0x16,
  0x1e,
  0x16,
  0x46,
  0x7f,
  0x00, // U+0045 (E)
  0x7f,
  0x46,
  0x16,
  0x1e,
  0x16,
  0x06,
  0x0f,
  0x00, // U+0046 (F)
  0x3c,
  0x66,
  0x03,
  0x03,
  0x73,
  0x66,
  0x7c,
  0x00, // U+0047 (G)
  0x33,
  0x33,
  0x33,
  0x3f,
  0x33,
  0x33,
  0x33,
  0x00, // U+0048 (H)
  0x1e,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x1e,
  0x00, // U+0049 (I)
  0x78,
  0x30,
  0x30,
  0x30,
  0x33,
  0x33,
  0x1e,
  0x00, // U+004A (J)
  0x67,
  0x66,
  0x36,
  0x1e,
  0x36,
  0x66,
  0x67,
  0x00, // U+004B (K)
  0x0f,
  0x06,
  0x06,
  0x06,
  0x46,
  0x66,
  0x7f,
  0x00, // U+004C (L)
  0x63,
  0x77,
  0x7f,
  0x7f,
  0x6b,
  0x63,
  0x63,
  0x00, // U+004D (M)
  0x63,
  0x67,
  0x6f,
  0x7b,
  0x73,
  0x63,
  0x63,
  0x00, // U+004E (N)
  0x1c,
  0x36,
  0x63,
  0x63,
  0x63,
  0x36,
  0x1c,
  0x00, // U+004F (O)
  0x3f,
  0x66,
  0x66,
  0x3e,
  0x06,
  0x06,
  0x0f,
  0x00, // U+0050 (P)
  0x1e,
  0x33,
  0x33,
  0x33,
  0x3b,
  0x1e,
  0x38,
  0x00, // U+0051 (Q)
  0x3f,
  0x66,
  0x66,
  0x3e,
  0x36,
  0x66,
  0x67,
  0x00, // U+0052 (R)
  0x1e,
  0x33,
  0x07,
  0x0e,
  0x38,
  0x33,
  0x1e,
  0x00, // U+0053 (S)
  0x3f,
  0x2d,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x1e,
  0x00, // U+0054 (T)
  0x33,
  0x33,
  0x33,
  0x33,
  0x33,
  0x33,
  0x3f,
  0x00, // U+0055 (U)
  0x33,
  0x33,
  0x33,
  0x33,
  0x33,
  0x1e,
  0x0c,
  0x00, // U+0056 (V)
  0x63,
  0x63,
  0x63,
  0x6b,
  0x7f,
  0x77,
  0x63,
  0x00, // U+0057 (W)
  0x63,
  0x63,
  0x36,
  0x1c,
  0x1c,
  0x36,
  0x63,
  0x00, // U+0058 (X)
  0x33,
  0x33,
  0x33,
  0x1e,
  0x0c,
  0x0c,
  0x1e,
  0x00, // U+0059 (Y)
  0x7f,
  0x63,
  0x31,
  0x18,
  0x4c,
  0x66,
  0x7f,
  0x00, // U+005A (Z)
  0x1e,
  0x06,
  0x06,
  0x06,
  0x06,
  0x06,
  0x1e,
  0x00, // U+005B ([)
  0x03,
  0x06,
  0x0c,
  0x18,
  0x30,
  0x60,
  0x40,
  0x00, // U+005C (\)
  0x1e,
  0x18,
  0x18,
  0x18,
  0x18,
  0x18,
  0x1e,
  0x00, // U+005D (])
  0x08,
  0x1c,
  0x36,
  0x63,
  0x00,
  0x00,
  0x00,
  0x00, // U+005E (^)
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0xff, // U+005F (_)
  0x0c,
  0x0c,
  0x18,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+0060 (`)
  0x00,
  0x00,
  0x1e,
  0x30,
  0x3e,
  0x33,
  0x6e,
  0x00, // U+0061 (a)
  0x07,
  0x06,
  0x06,
  0x3e,
  0x66,
  0x66,
  0x3b,
  0x00, // U+0062 (b)
  0x00,
  0x00,
  0x1e,
  0x33,
  0x03,
  0x33,
  0x1e,
  0x00, // U+0063 (c)
  0x38,
  0x30,
  0x30,
  0x3e,
  0x33,
  0x33,
  0x6e,
  0x00, // U+0064 (d)
  0x00,
  0x00,
  0x1e,
  0x33,
  0x3f,
  0x03,
  0x1e,
  0x00, // U+0065 (e)
  0x1c,
  0x36,
  0x06,
  0x0f,
  0x06,
  0x06,
  0x0f,
  0x00, // U+0066 (f)
  0x00,
  0x00,
  0x6e,
  0x33,
  0x33,
  0x3e,
  0x30,
  0x1f, // U+0067 (g)
  0x07,
  0x06,
  0x36,
  0x6e,
  0x66,
  0x66,
  0x67,
  0x00, // U+0068 (h)
  0x0c,
  0x00,
  0x0e,
  0x0c,
  0x0c,
  0x0c,
  0x1e,
  0x00, // U+0069 (i)
  0x30,
  0x00,
  0x30,
  0x30,
  0x30,
  0x33,
  0x33,
  0x1e, // U+006A (j)
  0x07,
  0x06,
  0x66,
  0x36,
  0x1e,
  0x36,
  0x67,
  0x00, // U+006B (k)
  0x0e,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x0c,
  0x1e,
  0x00, // U+006C (l)
  0x00,
  0x00,
  0x33,
  0x7f,
  0x7f,
  0x6b,
  0x63,
  0x00, // U+006D (m)
  0x00,
  0x00,
  0x1f,
  0x33,
  0x33,
  0x33,
  0x33,
  0x00, // U+006E (n)
  0x00,
  0x00,
  0x1e,
  0x33,
  0x33,
  0x33,
  0x1e,
  0x00, // U+006F (o)
  0x00,
  0x00,
  0x3b,
  0x66,
  0x66,
  0x3e,
  0x06,
  0x0f, // U+0070 (p)
  0x00,
  0x00,
  0x6e,
  0x33,
  0x33,
  0x3e,
  0x30,
  0x78, // U+0071 (q)
  0x00,
  0x00,
  0x3b,
  0x6e,
  0x66,
  0x06,
  0x0f,
  0x00, // U+0072 (r)
  0x00,
  0x00,
  0x3e,
  0x03,
  0x1e,
  0x30,
  0x1f,
  0x00, // U+0073 (s)
  0x08,
  0x0c,
  0x3e,
  0x0c,
  0x0c,
  0x2c,
  0x18,
  0x00, // U+0074 (t)
  0x00,
  0x00,
  0x33,
  0x33,
  0x33,
  0x33,
  0x6e,
  0x00, // U+0075 (u)
  0x00,
  0x00,
  0x33,
  0x33,
  0x33,
  0x1e,
  0x0c,
  0x00, // U+0076 (v)
  0x00,
  0x00,
  0x63,
  0x6b,
  0x7f,
  0x7f,
  0x36,
  0x00, // U+0077 (w)
  0x00,
  0x00,
  0x63,
  0x36,
  0x1c,
  0x36,
  0x63,
  0x00, // U+0078 (x)
  0x00,
  0x00,
  0x33,
  0x33,
  0x33,
  0x3e,
  0x30,
  0x1f, // U+0079 (y)
  0x00,
  0x00,
  0x3f,
  0x19,
  0x0c,
  0x26,
  0x3f,
  0x00, // U+007A (z)
  0x38,
  0x0c,
  0x0c,
  0x07,
  0x0c,
  0x0c,
  0x38,
  0x00, // U+007B ({)
  0x18,
  0x18,
  0x18,
  0x00,
  0x18,
  0x18,
  0x18,
  0x00, // U+007C (|)
  0x07,
  0x0c,
  0x0c,
  0x38,
  0x0c,
  0x0c,
  0x07,
  0x00, // U+007D (})
  0x6e,
  0x3b,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+007E (~)
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00,
  0x00, // U+007F
];

const characterSet = new Uint8ClampedArray(256 * 8);

const setCharacter = (index, tile) => {
  for (let i = 0; i < 8; i++) {
    characterSet[index * 8 + i] = tile[i];
  }
};

for (let i = 33; i <= 126; i++) {
  for (let x = 0; x < 8; x++) {
    const indexFrom = i * 8 + x;
    const indexTo = indexFrom - 32 * 8;

    characterSet[indexTo] = rawTileset[indexFrom];
  }
}

// All writeable ascii characters are now from 1 to 94, custom characters can go from 95 to 127
setCharacter(95, [0x80, 0x40, 0x20, 0x10, 0x8, 0x4, 0x2, 0x1]); // /
setCharacter(96, [0x1, 0x2, 0x4, 0x8, 0x10, 0x20, 0x40, 0x80]); // \
setCharacter(97, [0x81, 0x42, 0x24, 0x18, 0x18, 0x24, 0x42, 0x81]); // X
setCharacter(98, [0x0, 0x0, 0xf0, 0x8, 0x4, 0xe4, 0x24, 0x24]); // Top-left corner
setCharacter(99, [0x0, 0x0, 0xff, 0x0, 0x0, 0xff, 0x0, 0x0]); // Horizontal
setCharacter(100, [0x0, 0x0, 0xf, 0x10, 0x20, 0x27, 0x24, 0x24]); // Top-right corner
setCharacter(101, [0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24]); // Vertical
setCharacter(102, [0x24, 0x24, 0xe7, 0x0, 0x0, 0xe7, 0x24, 0x24]); // Cross junction
setCharacter(103, [0x24, 0x24, 0xe4, 0x4, 0x8, 0xf0, 0x0, 0x0]); // Bottom-left corner
setCharacter(104, [0x24, 0x24, 0x27, 0x20, 0x10, 0xf, 0x0, 0x0]); // Bottom-right corner
setCharacter(105, [0x30, 0x58, 0x3c, 0x76, 0x7e, 0x7e, 0x3c, 0x18]); //Bomb
setCharacter(106, [0x18, 0x1c, 0x3e, 0xf6, 0xe8, 0x64, 0x2, 0x1]); //Axe
setCharacter(107, [0x0, 0x66, 0x99, 0x81, 0x42, 0x24, 0x18, 0x0]); //Heart

// Create the reverse versions in the upper half
for (let i = 0; i < 128 * 8; i++) {
  const copyFrom = i;
  const copyTo = i + 128 * 8;

  const inverted =
    (characterSet[copyFrom] & 1 ? 0 : 1) |
    (characterSet[copyFrom] & 2 ? 0 : 2) |
    (characterSet[copyFrom] & 4 ? 0 : 4) |
    (characterSet[copyFrom] & 8 ? 0 : 8) |
    (characterSet[copyFrom] & 16 ? 0 : 16) |
    (characterSet[copyFrom] & 32 ? 0 : 32) |
    (characterSet[copyFrom] & 64 ? 0 : 64) |
    (characterSet[copyFrom] & 128 ? 0 : 128);

  characterSet[copyTo] = inverted;

  //   console.log(
  //     `Copying from ${copyFrom} to ${copyTo}, ${characterSet[copyFrom]} => ${characterSet[copyTo]}}`
  //   );
}

fs.writeFileSync("charset.json", JSON.stringify([...characterSet], null, 2));
fs.writeFileSync("charset.bin", Buffer.from(characterSet));
