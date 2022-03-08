import React from 'react'
import { ChevronsRight, Play } from 'react-feather'
import styled from 'styled-components'
import { useMachineContext } from '../../context/machine'

const ToolbarContainer = styled.div`
  display: flex;
  gap: 5px;
`

const ToolbarButton = styled.button`
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2px;
  border-color: 1px solid white;
  background-color: transparent;

  :disabled {
    opacity: 0.5;
  }

  svg {
    color: white;
  }
`

const Toolbar: React.FunctionComponent = () => {
  const { debuggerRunning } = useMachineContext()

  return (
    <ToolbarContainer>
      <ToolbarButton
        type="button"
        onClick={() => window.Main.stepDebugger()}
        title="Step"
        disabled={debuggerRunning}
      >
        <ChevronsRight />
      </ToolbarButton>

      <ToolbarButton
        type="button"
        onClick={() => window.Main.run()}
        title="Run"
        disabled={debuggerRunning}
      >
        <Play />
      </ToolbarButton>
    </ToolbarContainer>
  )
}

export default Toolbar
