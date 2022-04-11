import React, { useState } from 'react'
import { toHex } from '../../../electron/utils/output'
import { ManagedAddressInput } from '../AddressInput'
import { useMachineContext } from '../../context/machine'
import styled from 'styled-components'
import { BorderColor } from '../../styles'
import { X } from 'react-feather'

const Content = styled.div`
  margin: 0px 10px 5px 10px;
`

const MemoryValuesContainer = styled.div`
  margin-top: 5px;
  display: flex;
  flex-wrap: wrap;
  gap: 3px;
`

const MemoryValueContainer = styled.span`
  display: inline-flex;
  border: 0.5px solid ${BorderColor};
  padding: 2px;
  align-items: center;
  border-radius: 4px;

  button {
    background: none;
    padding: 0;
    margin: 2px;
    color: white;
    width: 18px;
    height: 18px;
  }
`

const MemoryWatch: React.FunctionComponent = () => {
  const [watches, setWatches] = useState<number[]>([])

  const onNewWatch = (address: number) => {
    if (watches.some(x => x === address)) return

    setWatches(x => [...x, address])
  }

  return (
    <Content>
      <ManagedAddressInput onAddressEntered={onNewWatch} />

      <MemoryValuesContainer>
        {watches.map(x => (
          <MemoryValueContainer key={x}>
            <span style={{ color: 'gray' }}>
              {toHex(x, 4, true)}&nbsp;=&nbsp;
            </span>
            <MemoryValue address={x} />
            <button
              type="button"
              onClick={() => setWatches(z => z.filter(a => a !== x))}
            >
              <X size="14px" />
            </button>
          </MemoryValueContainer>
        ))}
      </MemoryValuesContainer>
    </Content>
  )
}

interface MemoryValueProps {
  address: number
}

const MemoryValue: React.FunctionComponent<MemoryValueProps> = ({
  address,
}) => {
  const { memoryDump } = useMachineContext()

  return <>{toHex(memoryDump?.[address] ?? 0, 2, true)}</>
}

export default MemoryWatch
