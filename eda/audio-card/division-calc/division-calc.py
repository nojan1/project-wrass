baseNote = 440.0  # A4
baseClockFrequency = 1000000.0
stepRange = 60


def calc(numHalfsteps):
    twelthRoot = 1.059463094359
    return baseNote * pow(twelthRoot, numHalfsteps)


def findDivisor(targetFrequency):
    # targetFrequency = baseClockFrequency / divisor
    # divisor * targetFre = baseClock
    # baseClock = targetFreq
    idealDivision = (baseClockFrequency / 2) / targetFrequency
    possibleDivision = int(idealDivision)
    error = idealDivision - possibleDivision
    error2 = (possibleDivision + 1) - idealDivision
    return (
        (possibleDivision, error) if error < error2 else (possibleDivision + 1, error2)
    )


for i in range(-stepRange, stepRange):
    frequenzy = calc(i)
    (division, error) = findDivisor(frequenzy)
    print(f"{i}\t{frequenzy}Hz\t{division}\t{error}")
