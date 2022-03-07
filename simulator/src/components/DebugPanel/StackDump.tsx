import React from 'react'
import { useMachineContext } from '../../context/machine'

const StackDump: React.FunctionComponent = () => {
  const { stackDump } = useMachineContext()

  if (!stackDump) return null

  return <pre>{stackDump}</pre>
}

export default StackDump
