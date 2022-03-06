import React from 'react'
import styled from 'styled-components'

const LayoutContainer = styled.div`
  width: 100vw;
  height: 100vh;
  display: flex;
`

const Layout: React.FunctionComponent = ({ children }) => {
  return <LayoutContainer>{children}</LayoutContainer>
}

export default Layout
