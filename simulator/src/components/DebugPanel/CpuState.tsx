import React from 'react'
import { useCpuState } from '../../hooks'
import HexDisplay from '../HexDisplay'

const CpuState: React.FunctionComponent = () => {
  const cpuState = useCpuState()

  return (
    <table cellSpacing="10px">
      <tbody>
        <tr>
          <td>
            <b>SP: </b> <HexDisplay value={cpuState?.s} digits={2} />
          </td>
          <td>
            <b>PC: </b> <HexDisplay value={cpuState?.p} />
          </td>
          <td>
            <b>FLAGS: </b> <HexDisplay value={cpuState?.flags} digits={2} />
          </td>
        </tr>
        <tr>
          <td>
            <b>A: </b> <HexDisplay value={cpuState?.a} digits={2} />
          </td>
          <td>
            <b>X: </b> <HexDisplay value={cpuState?.x} digits={2} />
          </td>
          <td>
            <b>Y: </b> <HexDisplay value={cpuState?.y} digits={2} />
          </td>
        </tr>
      </tbody>
    </table>
  )
}

export default CpuState
