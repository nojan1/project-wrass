import React from 'react'
import { useStackDump } from '../../hooks'

const StackDump: React.FunctionComponent = () => {
  const stackDump = useStackDump()

  if (!stackDump) return null

  return <pre>{stackDump}</pre>
}

export default StackDump
