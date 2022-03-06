import React from 'react'
import { useDissasembly } from '../../hooks'

const Dissasembly: React.FunctionComponent = () => {
  const dissasembly = useDissasembly()

  if (!dissasembly) return null

  return <pre>{dissasembly}</pre>
}

export default Dissasembly
