import { useEffect, useState } from 'react'

export const useBridgeBoundState = <T>(channel: string) => {
  const [state, setState] = useState<T | undefined>()

  useEffect(() => {
    if (!window.Main) return

    window.Main.on(channel, (data: any) => {
      setState(data)
    })
  }, [window.Main])

  return state
}
