import React from 'react'
import styled from 'styled-components'
import { BorderColor } from '../../styles'
import LcdDisplay from '../LcdDisplay'

const OutputPanelontainer = styled.div`
  flex-grow: 1;
  margin: 5px;
  padding: 5px;
  border: 1px solid ${BorderColor};
  display: flex;
  justify-content: center;
  align-items: center;
`

const OutputPanel: React.FunctionComponent = () => {
  return (
    <OutputPanelontainer>
      <LcdDisplay />
    </OutputPanelontainer>
  )
}

export default OutputPanel
