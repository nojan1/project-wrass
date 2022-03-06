import React from 'react'
import styled from 'styled-components'
import { useDebuggerRunning } from '../../hooks'
import { PanelBackground } from '../../styles'
import CpuState from './CpuState'
import Dissasembly from './Dissasembly'
import LastTrap from './LastTrap'
import StackDump from './StackDump'

const PanelOuterContainer = styled.div`
  padding: 10px;
  background-color: ${PanelBackground};
  flex-basis: 30%;
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
  const debuggerRunning = useDebuggerRunning()

  return (
    <PanelOuterContainer>
      <button type="button" onClick={() => window.Main.stepDebugger()}>
        Step
      </button>
      <InfoSection $inactive={debuggerRunning ?? false}>
        <CpuState />
        <Dissasembly />
        <StackDump />
        <LastTrap />
      </InfoSection>
    </PanelOuterContainer>
  )
}

export default DebugPanel
