import React from 'react'
import { useMachineContext } from '../../context/machine'
import HexDisplay from '../HexDisplay'

const CpuState: React.FunctionComponent = () => {
  const { stateObject } = useMachineContext()

  return (
    <table cellSpacing="10px">
      <tbody>
        <tr>
          <td>
            <b>SP: </b> <HexDisplay value={stateObject?.s} digits={2} />
          </td>
          <td>
            <b>PC: </b> <HexDisplay value={stateObject?.p} />
          </td>
          <td>
            <b>FLAGS: </b> <HexDisplay value={stateObject?.flags} digits={2} />
          </td>
        </tr>
        <tr>
          <td>
            <b>A: </b> <HexDisplay value={stateObject?.a} digits={2} />
          </td>
          <td>
            <b>X: </b> <HexDisplay value={stateObject?.x} digits={2} />
          </td>
          <td>
            <b>Y: </b> <HexDisplay value={stateObject?.y} digits={2} />
          </td>
        </tr>
      </tbody>
    </table>
  )
}

export default CpuState
