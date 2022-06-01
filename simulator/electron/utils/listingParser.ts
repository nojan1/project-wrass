import fs from 'fs'

const targetLine = 'Symbols by value:'

export interface SymbolListing {
  symbols: Array<[number, string]>
  breakpoints: Array<[number, string]>
}

const getSymbols = (lines: string[]) => {
  const symbols: Array<[number, string]> = []

  const targetLineIndex = lines.findIndex(x => x?.startsWith(targetLine))

  if (targetLineIndex !== -1) {
    lines.slice(targetLineIndex + 1).forEach(line => {
      const [address, name] = line.trim().split(' ')
      if (!address || !name) return

      symbols.push([parseInt(address, 16), name])
    })
  }

  return symbols
}

const getBreakpointsFromComments = (lines: string[]) => {
  const breakpoints: Array<[number, string]> = []

  for (let i = 0; i < lines.length; i++) {
    const matches = /; (brk|break) (.*?)$/gi.exec(lines[i])
    if (matches) {
      const name = matches[2] ?? ''
      let address: number | undefined

      while (!address && i < lines.length - 1) {
        const nextLine = lines[i++]
        const addressMatches = /^([a-z0-9]*):([a-z0-9]*)\s*/gi.exec(nextLine)
        if (addressMatches) address = parseInt(addressMatches[2], 16)
      }

      if (address) breakpoints.push([address, name])
    }
  }

  return breakpoints
}

export const parseListing = (path: string) =>
  new Promise<SymbolListing>((resolve, reject) => {
    fs.readFile(
      path,
      {
        encoding: 'utf-8',
      },
      (err, data) => {
        if (err) reject(err)
        else {
          const lines = data.split('\n')

          const symbols = getSymbols(lines)
          const breakpointsFromSymbols = symbols.filter(
            ([_, name]) => name.startsWith('break') || name.startsWith('brk')
          )

          const breakpointsFromComments = getBreakpointsFromComments(lines)

          resolve({
            symbols,
            breakpoints: [
              ...breakpointsFromSymbols,
              ...breakpointsFromComments,
            ],
          })
        }
      }
    )
  })
