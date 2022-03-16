import { SymbolListing } from './listingParser'

export const toHex = (value: number, length = 4, includePrefix = true) =>
  `${includePrefix ? '$' : ''}${value
    .toString(16)
    .toUpperCase()
    .padStart(length, '0')}`

export const annotateDisassembly = (
  disassembly: string,
  symbols: SymbolListing
) => {
  const lines = disassembly.split('\n')

  for (let i = 0; i < lines.length; i++) {
    const parts = lines[i].split(/\s+/)
    if (parts.length < 2) continue

    const symbolNames = []
    for (let x = 3; x < parts.length; x++) {
      if (parts[x]?.startsWith('$')) {
        const address = parseInt(parts[x].substring(1), 16)
        const matchingSymbol = symbols.symbols.find(
          ([addr]) => addr === address
        )

        if (matchingSymbol) {
          symbolNames.push(matchingSymbol[1])
        }
      }
    }

    if (symbolNames.length) {
      lines[i] += ` ${symbolNames.join()}`
    }
  }

  return lines.join('\n')
}
