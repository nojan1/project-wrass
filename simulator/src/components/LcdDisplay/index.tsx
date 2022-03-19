import React from 'react'
import styled from 'styled-components'
import { useLcdText } from '../../hooks'

const NUM_COLS = 20
const NUM_ROWS = 4

const DisplayOuter = styled.div`
  display: flex;
  border: 1px solid #b8b8b82b;
  background-color: #0f0f0f;
  padding: 20px;
`

const DisplayInner = styled.div`
  flex-grow: 1;
  background-color: #003805;
  display: grid;
  grid-template-columns: repeat(${NUM_COLS}, auto);
  grid-template-rows: repeat(${NUM_ROWS}, auto);
  padding: 5px;
`

const Digit = styled.div`
  font-family: monospace;
  background-color: #005f18;
  color: black;
  font-weight: bold;
  font-size: 24px;
  width: 24px;
  height: 24px;
  line-height: 24px;
  vertical-align: center;
  text-align: center;
  margin: 2px;
`

const LcdDisplay: React.FunctionComponent = () => {
  const text = useLcdText() ?? ''

  return (
    <DisplayOuter>
      <DisplayInner>
        {Array.from(text.padEnd(NUM_COLS * NUM_ROWS, ' ')).map((c, i) => (
          <Digit key={i}>{c}</Digit>
        ))}
      </DisplayInner>
    </DisplayOuter>
  )
}

export default LcdDisplay
