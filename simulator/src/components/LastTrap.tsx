import React from 'react'
import { useMachineContext } from '../context/machine'

const LastTrap: React.FunctionComponent = () => {
  const { lastTrap } = useMachineContext()

  return (
    <span>
      Last trap: {lastTrap?.reason} {lastTrap?.message}
    </span>
  )
}

export default LastTrap
