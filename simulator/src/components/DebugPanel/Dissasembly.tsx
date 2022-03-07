import React from 'react'
import { useMachineContext } from '../../context/machine'

const Dissasembly: React.FunctionComponent = () => {
  const { disassembly } = useMachineContext()

  if (!disassembly) return null

  return <pre>{disassembly}</pre>
}

export default Dissasembly
