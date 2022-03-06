import React from 'react'
import { useLastTrap } from '../../hooks'

const LastTrap: React.FunctionComponent = () => {
  const lastTrap = useLastTrap()

  if (!lastTrap) return null

  return (
    <span>
      Last trap: {lastTrap?.reason} {lastTrap?.message}
    </span>
  )
}

export default LastTrap
