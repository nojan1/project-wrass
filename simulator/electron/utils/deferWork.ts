export const deferWork = <T>(callback: () => T) =>
  new Promise<T>(resolve => {
    setTimeout(() => {
      const returnValue = callback()
      resolve(returnValue)
    })
  })
