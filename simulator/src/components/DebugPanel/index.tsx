import React from 'react'
import styled from 'styled-components'
import { useMachineContext } from '../../context/machine'
import { PanelBackground } from '../../styles'
import GroupBox from '../GroupBox'
import CpuState from './CpuState'
import Dissasembly from './Dissasembly'
import StackDump from './StackDump'
import Toolbar from './Toolbar'

const PanelOuterContainer = styled.div`
  padding: 10px;
  background-color: ${PanelBackground};
  flex-basis: 30%;
  display: flex;
  flex-direction: column;
`

const InfoSection = styled.div<{ $inactive: boolean }>`
  ${props =>
    props.$inactive
      ? `
user-select: none;
`
      : ''}
`

const DebugPanel: React.FunctionComponent = () => {
  const { debuggerRunning } = useMachineContext()

  return (
    <PanelOuterContainer>
      <Toolbar />
      <InfoSection $inactive={debuggerRunning ?? false}>
        <GroupBox title="State">
          <CpuState />
        </GroupBox>
        <GroupBox title="Disassembly">
          <Dissasembly />
        </GroupBox>
        <GroupBox title="Stack" scroll={true}>
          <StackDump />
        </GroupBox>
      </InfoSection>
    </PanelOuterContainer>
  )
}

export default DebugPanel
