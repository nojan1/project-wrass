import React from 'react'
import styled from 'styled-components'
import { BorderColor } from '../../styles'

const OutputPanelontainer = styled.div`
  flex-grow: 1;
  margin: 5px;
  padding: 5px;
  border: 1px solid ${BorderColor};
`

const OutputPanel: React.FunctionComponent = () => {
  return <OutputPanelontainer>Haha hahahahaha</OutputPanelontainer>
}

export default OutputPanel
