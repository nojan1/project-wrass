import React from 'react'
import styled from 'styled-components'
import { BorderColor, PanelBackground } from '../../styles'

const Container = styled.div`
  display: flex;
  gap: 5px;
`

const Indicator = styled.div<{ $isSet: boolean }>`
  border: 0.5px solid ${BorderColor};
  width: 30px;
  height: 30px;
  display: flex;
  justify-content: center;
  align-items: center;

  ${props =>
    props.$isSet
      ? `
    background-color: white;
    color: ${PanelBackground};
`
      : `
    background-color: ${PanelBackground};
    color: white;
`}
`

export interface FlagsDisplayProps {
  flags: number
}

const FlagsDisplay: React.FunctionComponent<FlagsDisplayProps> = ({
  flags,
}) => {
  return (
    <Container>
      <Indicator $isSet={!!(flags & (1 << 7))}>N</Indicator>
      <Indicator $isSet={!!(flags & (1 << 6))}>V</Indicator>
      <Indicator $isSet={!!(flags & (1 << 5))}>-</Indicator>
      <Indicator $isSet={!!(flags & (1 << 4))}>B</Indicator>
      <Indicator $isSet={!!(flags & (1 << 3))}>D</Indicator>
      <Indicator $isSet={!!(flags & (1 << 2))}>I</Indicator>
      <Indicator $isSet={!!(flags & (1 << 1))}>Z</Indicator>
      <Indicator $isSet={!!(flags & (1 << 0))}>C</Indicator>
    </Container>
  )
}

export default FlagsDisplay
