import React from 'react'
import styled from 'styled-components'
import { BorderColor } from '../../styles'
import GraphicDisplay from '../GraphicDisplay'
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
  const display = new URLSearchParams(window.location.search).get('display')

  return (
    <OutputPanelontainer>
      {display === 'graphic' ? <GraphicDisplay /> : <LcdDisplay />}
    </OutputPanelontainer>
  )
}

export default OutputPanel
