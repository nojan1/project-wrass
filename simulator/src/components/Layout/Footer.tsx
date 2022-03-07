import React from 'react'
import styled from 'styled-components'

const FooterContainer = styled.div`
  width: 100vw;
  height: 30px;
`

const Footer: React.FunctionComponent = ({ children }) => {
  return <FooterContainer>{children}</FooterContainer>
}

export default Footer
