import React, { useEffect, useState } from 'react'
import styled from 'styled-components'
import { Breakpoint } from '../../../electron/types/breakpoint'
import { toHex } from '../../../electron/utils/output'
import { useMachineContext } from '../../context/machine'
import { BorderColor } from '../../styles'
import { ManagedAddressInput } from '../AddressInput'

const Checkbox = styled.input`
  background-color: transparent;
  color: white;
  border-color: ${BorderColor};
  outline-color: white;
  outline-width: 0.5px;
`

const BreakpointsTable = styled.table`
  border-spacing: 5px;

  td {
    vertical-align: top;
  }

  td:nth-child(3) {
    font-size: 0.8em;
  }
`

interface EnabledBreakpoint extends Breakpoint {
  enabled: boolean
}

const BreakpointsDisplay: React.FunctionComponent = () => {
  const { initialBreakpoints } = useMachineContext()
  const [breakpoints, setBreakpoints] = useState<EnabledBreakpoint[]>([])

  useEffect(() => {
    setBreakpoints(x => {
      initialBreakpoints?.forEach(b => {
        if (!x.find(b2 => b2.address === b.address))
          x.push({ ...b, enabled: true })
      })

      return x
    })
  }, [initialBreakpoints, setBreakpoints])

  const onBreakpointEnabled = (breakpoint: EnabledBreakpoint) => {
    setBreakpoints(x =>
      x.map(b => {
        if (b.address === breakpoint.address) b.enabled = true
        return b
      })
    )

    window.Main.addBreakpoint(breakpoint.address, breakpoint.description)
  }

  const onBreakpointDisabled = (breakpoint: EnabledBreakpoint) => {
    setBreakpoints(x =>
      x.map(b => {
        if (b.address === breakpoint.address) b.enabled = false
        return b
      })
    )

    window.Main.removeBreakpoint(breakpoint.address)
  }

  const onBreakpointAdded = (address: number) => {
    const newBreakpoint = {
      address,
      description: `Breakpoint at ${toHex(address, 4, true)}`,
      enabled: true,
    }
    setBreakpoints(b => [...b, newBreakpoint])
    onBreakpointEnabled(newBreakpoint)
  }

  return (
    <>
      <ManagedAddressInput
        onAddressEntered={address => onBreakpointAdded(address)}
      />

      <BreakpointsTable>
        <tbody>
          {breakpoints?.map(x => (
            <tr key={x.address}>
              <td>
                <Checkbox
                  type="checkbox"
                  checked={x.enabled}
                  onChange={e =>
                    e.target.checked
                      ? onBreakpointEnabled(x)
                      : onBreakpointDisabled(x)
                  }
                />
              </td>

              <td>
                <span>{toHex(x.address, 4, true)}</span>
              </td>
              <td>
                <span>{x.description}</span>
              </td>
            </tr>
          ))}
        </tbody>
      </BreakpointsTable>
    </>
  )
}

export default BreakpointsDisplay
