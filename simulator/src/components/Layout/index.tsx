import React from 'react'
import styled from 'styled-components'
import Footer from './Footer'

const LayoutContainer = styled.div`
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
`

const TopSection = styled.div`
  width: 100vw;
  flex-grow: 1;
  display: flex;
`

export interface LayoutProps {
  footer?: React.ReactNode
}

const Layout: React.FunctionComponent<LayoutProps> = ({ children, footer }) => {
  return (
    <LayoutContainer>
      <TopSection>{children}</TopSection>
      <Footer>{footer}</Footer>
    </LayoutContainer>
  )
}

export default Layout
