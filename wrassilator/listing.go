package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func parseListing(listingFilePath string) ([]uint16, map[uint16]string) {
	breakpoints := make([]uint16, 0)
	symbols := make(map[uint16]string)

	f, err := os.Open(listingFilePath)
	if err != nil {
		return breakpoints, symbols
	}

	scanner := bufio.NewScanner(f)

	inSymbolRegion := false
	for scanner.Scan() {
		if inSymbolRegion {
			parts := strings.Split(scanner.Text(), " ")

			addr, addrErr := strconv.ParseUint(parts[0], 16, 16)
			if addrErr != nil {
				fmt.Printf("Error parsing address on symbol line: %s \n", scanner.Text())
				continue
			}

			if strings.HasSuffix(parts[1], "brk") {
				breakpoints = append(breakpoints, uint16(addr))
			}

			existingValue, exists := symbols[uint16(addr)]
			if exists {
				symbols[uint16(addr)] = fmt.Sprintf("%s,%s", existingValue, parts[1])
			} else {
				symbols[uint16(addr)] = parts[1]
			}
		}

		if scanner.Text() == "Symbols by value:" {
			inSymbolRegion = true
		}

	}

	return breakpoints, symbols
}
