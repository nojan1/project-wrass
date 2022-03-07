import React from 'react'
import { useMachineContext } from '../context/machine'

const LastTrap: React.FunctionComponent = () => {
  const { lastTrap } = useMachineContext()

  if (!lastTrap) return null

  return (
    <span>
      Last trap: {lastTrap?.reason} {lastTrap?.message}
    </span>
  )
}

export default LastTrap
