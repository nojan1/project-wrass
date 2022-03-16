import React from 'react'
import styled from 'styled-components'
import { toHex } from '../../../electron/utils/output'
import { BorderColor } from '../../styles'

const MemoryAddessInputContainer = styled.div`
  position: relative;

  span {
    position: absolute;
    left: 10px;
    top: 4px;
  }

  input {
    padding: 5px 10px 5px 19px;
    background-color: transparent;
    color: white;
    border-color: ${BorderColor};
    outline-color: white;
    outline-width: 0.5px;
    width: 100%;
  }
`

const MemoryAddressInput: React.FunctionComponent<
  React.DetailedHTMLProps<
    React.InputHTMLAttributes<HTMLInputElement>,
    HTMLInputElement
  >
> = props => {
  return (
    <MemoryAddessInputContainer>
      <span>$</span>
      <input
        {...props}
        defaultValue={toHex(
          parseInt(props?.defaultValue?.toString() ?? '0'),
          4,
          false
        )}
        pattern="[0-9a-fA-F]*"
      />
    </MemoryAddessInputContainer>
  )
}

export default MemoryAddressInput
