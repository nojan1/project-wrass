import React, { useState } from 'react'
import styled from 'styled-components'
import { useMachineContext } from '../../context/machine'
import { PanelBackground } from '../../styles'
import BreakpointsDisplay from '../Breakpoints'
import GroupBox from '../GroupBox'
import MemoryExplorer from '../MemoryExplorer'
import MemoryWatch from '../MemoryWatch'
import CpuState from './CpuState'
import Dissasembly from './Dissasembly'
import StackDump from './StackDump'
import Toolbar from './Toolbar'

const PanelOuterContainer = styled.div`
  padding: 10px;
  background-color: ${PanelBackground};
  flex-basis: 35%;
  display: flex;
  flex-direction: column;
`

const Wrapper = styled.div`
  position: relative;
`

const InfoSectionOverlay = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  z-index: 10;
  width: 100%;
  height: 100%;
  background-color: ${PanelBackground};
  opacity: 0.9;
  display: flex;
  justify-content: center;
  align-items: center;
`

const DebugPanel: React.FunctionComponent = () => {
  const { debuggerRunning, stateObject } = useMachineContext()
  const [selectedMemoryAddress, setSelectedMemoryAddress] =
    useState<{ value: number }>()

  return (
    <PanelOuterContainer>
      <Toolbar
        onOpenMemoryExplorer={() =>
          setSelectedMemoryAddress(
            selectedMemoryAddress
              ? { ...selectedMemoryAddress }
              : { value: stateObject?.p ?? 0 }
          )
        }
      />
      <MemoryExplorer selectedAddress={selectedMemoryAddress} />
      <Wrapper>
        {debuggerRunning && (
          <InfoSectionOverlay>Debugger running</InfoSectionOverlay>
        )}
        <GroupBox title="State">
          <CpuState />
        </GroupBox>
        <GroupBox title="Disassembly">
          <Dissasembly />
        </GroupBox>
        <GroupBox title="Watches" scroll={true}>
          <MemoryWatch />
        </GroupBox>
        <GroupBox title="Stack" scroll={true} maxHeight="350px">
          <StackDump />
        </GroupBox>
        <GroupBox title="Breakpoints" scroll={true} maxHeight="350px">
          <BreakpointsDisplay />
        </GroupBox>
      </Wrapper>
    </PanelOuterContainer>
  )
}

export default DebugPanel
