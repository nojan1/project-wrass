import React from 'react'
import styled from 'styled-components'
import { PanelBackground } from '../../styles'

const FooterContainer = styled.div`
  width: 100vw;
  height: 30px;
  border: 1px solid black;
  background-color: ${PanelBackground};
  display: flex;
  align-items: center; ;
`

const Footer: React.FunctionComponent = ({ children }) => {
  return <FooterContainer>{children}</FooterContainer>
}

export default Footer
