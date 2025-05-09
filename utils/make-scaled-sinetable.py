import sys, math

scale = int(sys.argv[1] if len(sys.argv) > 1 else 5)

numValues = 256
countPerRow = 16

for i in range(int(numValues / countPerRow)):
    values = [
        str(int(math.sin(x + (i * countPerRow)) * scale)) for x in range(countPerRow)
    ]
    print(".db ", end="")
    print(", ".join(values))
