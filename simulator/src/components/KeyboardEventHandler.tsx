import React, { useCallback, useEffect } from 'react'
import { useMachineContext } from '../context/machine'

const KeyboardEventHandler: React.FunctionComponent = () => {
  const { debuggerRunning } = useMachineContext()

  const handleKeydown = useCallback(
    ev => {
      window.Main.keydown(ev.code)
    },
    [debuggerRunning]
  )

  const handleKeyUp = useCallback(
    ev => {
      window.Main.keyup(ev.code)
    },
    [debuggerRunning]
  )

  useEffect(() => {
    if (debuggerRunning) {
      document.addEventListener('keydown', handleKeydown)
      document.addEventListener('keyup', handleKeyUp)
    }

    return () => {
      document.removeEventListener('keydown', handleKeydown)
      document.removeEventListener('keyup', handleKeyUp)
    }
  }, [debuggerRunning])

  return <></>
}

export default KeyboardEventHandler
