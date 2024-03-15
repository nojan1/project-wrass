#!/usr/bin/env python3

from PIL import Image, ImageStat
from argparse import ArgumentParser

parser = ArgumentParser()
parser.add_argument("image")
parser.add_argument("--num-colors", "-c", type=int, default=16)
parser.add_argument("--width", "-x", type=int, default=40)
parser.add_argument("--height", "-y", type=int, default=30)
parser.add_argument("--dither", action="store_true")

args = parser.parse_args()


def toCustomColor(red, green, blue):
    newRed = int((red / 256) * 8)
    newGreen = int((green / 256) * 8)
    newBlue = int((blue / 256) * 4)

    return newRed << 5 | newGreen << 2 | newBlue


with Image.open(args.image) as inputImage:
    resizedImage = inputImage.resize((args.width, args.height))
    quantizedImage = resizedImage.quantize(
        colors=args.num_colors,
        dither=Image.FLOYDSTEINBERG if args.dither else Image.NONE,
    )

    rawPallete = quantizedImage.getpalette()
    print("; Pallete")
    print("image_pallete:")
    palletes = [
        str(toCustomColor(rawPallete[i], rawPallete[i + 1], rawPallete[i + 2]))
        for i in range(0, args.num_colors * 3, 3)
    ]
    print("\tdb " + ", ".join(palletes))

    print("")
    print("; Tiledata")
    print("image_chars:")
    for y in range(0, args.height):
        line = [str(128) for x in range(0, args.width)]
        print("\tdb " + ", ".join(line))

    print("")
    print("image_colorattributes:")
    for y in range(0, args.height):
        line = [str(quantizedImage.getpixel((x, y)) << 4) for x in range(0, args.width)]
        print("\tdb " + ", ".join(line))
