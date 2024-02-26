from PIL import Image, ImageStat
from argparse import ArgumentParser
import imagehash

parser = ArgumentParser()
parser.add_argument("image")
parser.add_argument("--num-colors", "-c", type=int, default=16)
parser.add_argument("--width", "-x", type=int, default=320)
parser.add_argument("--height", "-y", type=int, default=240)
parser.add_argument("--num-tiles", "-t", type=int, default=256)
parser.add_argument("--dither", action="store_true")

args = parser.parse_args()

with Image.open(args.image) as inputImage:
    resizedImage = inputImage.resize((args.width, args.height))
    resizedImage.save("resized.png")

    quantizedImage = resizedImage.quantize(
        colors=args.num_colors,
        dither=Image.FLOYDSTEINBERG if args.dither else Image.NONE,
    )
    quantizedImage.save("quantized.png")

    rawPallete = quantizedImage.getpalette()
    palleteData = []
    for i in range(0, args.num_colors * 3, 3):
        palleteData.append((rawPallete[i], rawPallete[i + 1], rawPallete[i + 2]))

    chunks = []
    chunkMappings = {}
    numChunks = 0
    for y in range(0, args.height, 8):
        for x in range(0, args.width, 8):
            chunk = quantizedImage.crop((x, y, x + 8, y + 8))
            chunks.append((chunk, ImageStat.Stat(chunk)))

            chunkMappings[numChunks] = numChunks
            numChunks += 1

    slush = 5
    while numChunks > args.num_tiles:
        didRemove = False
        for chunkNum, referenceNum in chunkMappings.items():
            for innerChunkNum, innerReferenceNum in chunkMappings.items():
                if referenceNum == innerReferenceNum or numChunks <= args.num_tiles:
                    continue

                (outerChunk, outerStat) = chunks[referenceNum]
                (innerChunk, innerStat) = chunks[innerReferenceNum]

                # rms = sum(outerStat.rms) / len(outerStat.rms)
                # rms2 = sum(innerStat.rms) / len(innerStat.rms)

                hash0 = imagehash.average_hash(outerChunk)
                hash1 = imagehash.average_hash(innerChunk)

                # if abs(rms - rms2) < slush:
                if abs(hash0 - hash1) < slush:
                    didRemove = True
                    chunkMappings[innerChunkNum] = referenceNum
                    numChunks -= 1

        if not didRemove:
            slush += 1

    outImage = quantizedImage.copy()
    numChunks = len(chunkMappings)
    for i in range(numChunks):
        x = (i * 8) % args.width
        y = int((i * 8) / args.height) * 8

        outImage.paste(chunks[chunkMappings[i]][0], (x, y))

    outImage.save("output.png")
