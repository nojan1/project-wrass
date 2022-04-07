from email.mime import base


baseAddr = 0xA000
size = 1024
numChunks = 16
chunkSize = int(size / numChunks)

for i, addr in enumerate(range(baseAddr, baseAddr + size, chunkSize)):
    print(f"| {i} | | ${addr:04X} | ${(addr + chunkSize - 1):04X} |")
