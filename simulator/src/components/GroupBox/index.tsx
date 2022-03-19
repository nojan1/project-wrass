import React from 'react'
import styled from 'styled-components'
import { PanelBackground } from '../../styles'

const GroupBoxContainer = styled.div`
  padding: 5px;
  margin: 10px 5px;
  border: 1px solid white;
`

const Title = styled.span`
  display: inline-block;
  position: relative;
  top: -15px;
  background-color: ${PanelBackground};
  padding: 0 5px;
`

const ContentContainer = styled.div<{ $scroll: boolean; $maxHeight: string }>`
  ${props =>
    props.$scroll
      ? `
        overflow-y: scroll;
        max-height: 400px;
    `
      : ''}

  max-height: ${props => props.$maxHeight};
`

export interface GroupBoxProps {
  title: string
  scroll?: boolean
  maxHeight?: string
}

const GroupBox: React.FunctionComponent<GroupBoxProps> = ({
  title,
  children,
  maxHeight = 'auto',
  scroll = false,
}) => {
  return (
    <GroupBoxContainer>
      {title && <Title>{title}</Title>}
      <ContentContainer $scroll={scroll} $maxHeight={maxHeight}>
        {children}
      </ContentContainer>
    </GroupBoxContainer>
  )
}

export default GroupBox
