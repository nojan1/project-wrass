import React from 'react'
import styled from 'styled-components'
import { useBlinkenLights } from '../../hooks'

const LightRow = styled.div`
  display: flex;
  justify-self: end;
`

const Light = styled.div<{ $isLit: boolean }>`
  width: 16px;
  height: 16px;
  border-radius: 100%;
  border: 1px solid black;

  background-color: ${props => (props.$isLit ? 'green' : 'gray')};
`

const BlinkenLights: React.FunctionComponent = () => {
  const lights = useBlinkenLights() ?? 0

  return (
    <LightRow>
      <Light $isLit={!!(lights & 0b1000)} />
      <Light $isLit={!!(lights & 0b0100)} />
      <Light $isLit={!!(lights & 0b0010)} />
      <Light $isLit={!!(lights & 0b0001)} />
    </LightRow>
  )
}

export default BlinkenLights
