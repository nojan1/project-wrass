from struct import *

ATTR_READ_ONLY = 0x01
ATTR_HIDDEN = 0x02
ATTR_SYSTEM = 0x04
ATTR_VOLUME_ID = 0x08
ATTR_DIRECTORY = 0x10
ATTR_ARCHIVE = 0x20
ATTR_LONG_NAME = ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID

fat_begin_lba = 0x2020
cluster_begin_lba = 15844
BPB_BytsPerSec = 512
BPB_SecPerClus = 0x40

f = open("/Users/nojan/Dev/6502-project/simulator/testfiles/sd-card.img", "rb")

def dosdate(timeWord, dateWord):
    day = dateWord & 0xF
    month = (dateWord >> 5) & 0xF
    year = (dateWord >> 9) + 1980

    second = timeWord & 0xF
    minutes = (timeWord >> 5) & 0x1F
    hours = timeWord >> 11

    return f"{year}:{month:02}:{day:02} {hours:02}:{minutes:02}:{second:02}"

def printroot():
    f.seek(cluster_begin_lba * BPB_BytsPerSec)
    data = f.read(BPB_BytsPerSec)

    print("Type\tName\tAttr\tSize\tCluster\tWrite date\tCreate date")
    for i in range(int(BPB_BytsPerSec / 32)):
        entryData = data[i * 32:(i + 1) * 32]
        (DIR_Name, DIR_Attr, DIR_NTRes, DIR_CrtTimeTenth, DIR_CrtTime, DIR_CrtDate, DIR_LstAccDate, DIR_FstClusHI, DIR_WrtTime, DIR_WrtDate, DIR_FstClusLO, DIR_FileSize) = unpack("11sBBBHHHHHHHI", entryData)

        if DIR_Name[0] == 0xE5 or DIR_Name[0] == 0x00:
            continue

        isDirectory = DIR_Attr & ATTR_DIRECTORY != 0
        isLongName = DIR_Attr & ATTR_LONG_NAME != 0
        isSystem = DIR_Attr & ATTR_SYSTEM != 0
        isHidden = DIR_Attr & ATTR_HIDDEN != 0
        isVolumeId = DIR_Attr & ATTR_VOLUME_ID != 0

        if isSystem or isHidden or isVolumeId:
            continue

        baseName = DIR_Name[0:7].decode('ascii').strip()
        extension = DIR_Name[8:11].decode('ascii')

        cluster = (DIR_FstClusHI << 4) | DIR_FstClusLO

        print(f"{"DIR" if isDirectory else extension}\t{baseName}\t{DIR_Attr:02X}\t{DIR_FileSize}\t{cluster}\t{dosdate(DIR_WrtTime, DIR_WrtDate)}\t{dosdate(DIR_CrtTime, DIR_CrtDate)}")

def readClusterChain(clusterNum):
    yield clusterNum

    f.seek((fat_begin_lba * BPB_BytsPerSec) + (clusterNum * 4)) # times 4 because of 32bit fats

    readData = f.read(4)
    (data,) = unpack("<I", readData)

    if data & 0xFFFFFF8 >= 0xFFFFFF8:
        return

    yield data
    yield from readClusterChain(data)

def getFileAtCluster(clusterNum):
    data = bytes()
    for cluster in readClusterChain(clusterNum):
        firstSectorOfCluster = cluster_begin_lba + ((cluster - 2) * BPB_SecPerClus)
        # print(f"First sector of cluster {firstSectorOfCluster:04X}")
        f.seek(firstSectorOfCluster * BPB_BytsPerSec)

        clusterData = f.read(BPB_BytsPerSec)
        data += clusterData

    return data

printroot()

print("\nContents of TEST.TXT")
text = getFileAtCluster(81)
print(text.decode('utf-8'))

print("\nContents of TEST.BIN")
data = getFileAtCluster(80)
print(data)