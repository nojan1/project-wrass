import React from 'react'

export interface HexDisplayProps {
  value?: number
  digits?: number
}

const HexDisplay: React.FunctionComponent<HexDisplayProps> = ({
  value = 0,
  digits = 4,
}) => {
  return <>{`$${value.toString(16).toUpperCase().padStart(digits, '0')}`}</>
}

export default HexDisplay
