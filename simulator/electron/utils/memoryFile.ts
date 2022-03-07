import fs from 'fs'

export const loadMemoryFromFile = async (path: string) => {
  console.log(`Loading data from ${path}`)

  return new Promise<Buffer>((resolve, reject) => {
    fs.readFile(
      path,
      {
        encoding: null,
      },
      (err, data) => {
        if (err) reject(err)
        else {
          resolve(data)
        }
      }
    )
  })
}
