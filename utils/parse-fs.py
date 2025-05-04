from struct import *
import sys

ATTR_READ_ONLY = 0x01
ATTR_HIDDEN = 0x02
ATTR_SYSTEM = 0x04
ATTR_VOLUME_ID = 0x08
ATTR_DIRECTORY = 0x10
ATTR_ARCHIVE = 0x20
ATTR_LONG_NAME = ATTR_READ_ONLY | ATTR_HIDDEN | ATTR_SYSTEM | ATTR_VOLUME_ID

fat_begin_lba = 0x2020
cluster_begin_lba = 0x3de4 #15844
BPB_BytsPerSec = 0x200 #512
BPB_SecPerClus = 0x40

image = sys.argv[1] if len(sys.argv) > 1 else "../simulator/testfiles/sd-card.img"
#f = open("../simulator/testfiles/sd-card.img", "rb")
f = open(image, "rb")

def dosdate(timeWord, dateWord):
    day = dateWord & 0xF
    month = (dateWord >> 5) & 0xF
    year = (dateWord >> 9) + 1980

    second = timeWord & 0xF
    minutes = (timeWord >> 5) & 0x1F
    hours = timeWord >> 11

    return f"{year}:{month:02}:{day:02} {hours:02}:{minutes:02}:{second:02}"

def printroot():
    for cluster in readClusterChain(2):
        sectorsData = getSectorDataForCluster(cluster)

        print("Type\tName\tAttr\tSize\tCluster\tWrite date\tCreate date")
        for data in sectorsData:
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

    # f.seek((fat_begin_lba * BPB_BytsPerSec) + (clusterNum * 4)) # times 4 because of 32bit fats
    # readData = f.read(4)
    # (data,) = unpack("<I", readData)

    fat_sector = fat_begin_lba + int(clusterNum / 128)
    # print(f"Got fat_sector = {fat_sector:08X} for cluster {clusterNum}")

    f.seek(fat_sector * BPB_BytsPerSec)
    readData = f.read(512)

    bufferOffset = (clusterNum & 0x7F) << 2
    # print(f"Buffer offset {bufferOffset:02X}")
 
    (data,) = unpack("<I", readData[bufferOffset:bufferOffset + 4])

    # print(f"FAT returned {data:08X}")

    if data & 0xFFFFFF8 >= 0xFFFFFF8 or data == 0:
        return

    yield data

    yield from readClusterChain(data)

def getSectorDataForCluster(clusterNum):
    firstSectorOfCluster = cluster_begin_lba + ((clusterNum - 2) * BPB_SecPerClus)
    print(f"Calculated sector offset for cluster {clusterNum} is {firstSectorOfCluster:08X}")

    data = []
    for i in range(BPB_SecPerClus):
        f.seek((firstSectorOfCluster + i) * BPB_BytsPerSec)
        data.append(f.read(BPB_BytsPerSec))

    return data

def getFileAtCluster(clusterNum, size):
    data = bytes()
    for cluster in readClusterChain(clusterNum):
        for d in getSectorDataForCluster(cluster):
            data += d

    return data

def parseHeaders():
    global fat_begin_lba, cluster_begin_lba, BPB_BytsPerSec, BPB_SecPerClus

    # Partition 1
    f.seek(0x01BE)
    data = f.read(16)
    (status,partitionType,partitionLba,partitionLength) = unpack("B3xB3xII", data)

    print(f"Found partion 1 at {partitionLba:08X} having type {partitionType:02X}")

    # FAT Header
    f.seek(partitionLba * 512)
    data = f.read(512)

    (BPB_BytsPerSec,) = unpack("H", data[0x0B:0X0B + 2])
    (BPB_SecPerClus,) = unpack("B", data[0x0D:0x0D + 1])
    (BPB_RsvdSecCnt,) = unpack("H", data[0x0E:0x0E + 2])
    (BPB_FATSz32,) = unpack("I", data[0x24:0x24 + 4])
    (BPB_RootClus,) = unpack("I", data[0x2C:0x2C + 4])

    fat_begin_lba = partitionLba + BPB_RsvdSecCnt
    cluster_begin_lba = partitionLba + BPB_RsvdSecCnt + (2 * BPB_FATSz32);
    bytes_per_cluster = BPB_SecPerClus * BPB_BytsPerSec

    print(f"BPB_BytsPerSec={BPB_BytsPerSec:04X} ({BPB_BytsPerSec})")
    print(f"BPB_SecPerClus={BPB_SecPerClus:02X} ({BPB_SecPerClus})") 
    print(f"BPB_RsvdSecCnt={BPB_RsvdSecCnt:04X} ({BPB_RsvdSecCnt})") 
    print(f"BPB_FATSz32={BPB_FATSz32:08X} ({BPB_FATSz32})") 
    print(f"BPB_RootClus={BPB_RootClus:08X} ({BPB_RootClus})")
    print(f"fat_begin_lba={fat_begin_lba:08X} ({fat_begin_lba})") 
    print(f"cluster_begin_lba={cluster_begin_lba:08X} ({cluster_begin_lba}) - byte offset {cluster_begin_lba * 512}")
    print(f"bytes_per_cluster={bytes_per_cluster:08X} ({bytes_per_cluster})")

parseHeaders()
printroot()

# print("\nContents of TEST.TXT")
# text = getFileAtCluster(81)
# print(text.decode('utf-8'))

# print("\nContents of TEST.BIN")
# data = getFileAtCluster(80)
# print(data)