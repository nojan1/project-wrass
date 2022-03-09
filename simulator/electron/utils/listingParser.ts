import fs from 'fs'

const targetLine = 'Symbols by value:'

export interface SymbolListing {
  symbols: Array<[number, string]>
  breakpoints: Array<[number, string]>
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
          const symbols: Array<[number, string]> = []

          const lines = data.split('\n')
          const targetLineIndex = lines.findIndex(x =>
            x?.startsWith(targetLine)
          )

          if (targetLineIndex !== -1) {
            lines.slice(targetLineIndex + 1).forEach(line => {
              const [address, name] = line.trim().split(' ')
              if (!address || !name) return

              symbols.push([parseInt(address, 16), name])
            })
          }

          resolve({
            symbols,
            breakpoints: symbols.filter(
              ([_, name]) => name.startsWith('break') || name.startsWith('brk')
            ),
          })
        }
      }
    )
  })
