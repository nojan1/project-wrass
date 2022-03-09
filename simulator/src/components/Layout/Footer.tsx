import React from 'react'
import styled from 'styled-components'
import { PanelBackground } from '../../styles'

const FooterContainer = styled.div`
  width: 100vw;
  height: 30px;
  border: 1px solid black;
  background-color: ${PanelBackground};
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 10px;
`

const Footer: React.FunctionComponent = ({ children }) => {
  return <FooterContainer>{children}</FooterContainer>
}

export default Footer
