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

const ContentContainer = styled.div<{ $scroll: boolean }>`
  ${props =>
    props.$scroll
      ? `
        overflow-y: scroll;
        max-height: 400px;
    `
      : ''}
`

export interface GroupBoxProps {
  title: string
  scroll?: boolean
}

const GroupBox: React.FunctionComponent<GroupBoxProps> = ({
  title,
  children,
  scroll = false,
}) => {
  return (
    <GroupBoxContainer>
      {title && <Title>{title}</Title>}
      <ContentContainer $scroll={scroll}>{children}</ContentContainer>
    </GroupBoxContainer>
  )
}

export default GroupBox
