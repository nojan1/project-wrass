import React, { FormEvent } from 'react'
import styled from 'styled-components'
import { toHex } from '../../electron/utils/output'
import { BorderColor } from '../styles'

const AddressInputContainer = styled.div`
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

const AddressInput: React.FunctionComponent<
  React.DetailedHTMLProps<
    React.InputHTMLAttributes<HTMLInputElement>,
    HTMLInputElement
  >
> = props => {
  return (
    <AddressInputContainer>
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
    </AddressInputContainer>
  )
}

export interface ManagedAddressInputProps {
  onAddressEntered: (address: number) => void
}

export const ManagedAddressInput: React.FunctionComponent<
  ManagedAddressInputProps
> = ({ onAddressEntered }) => {
  const onSubmit = (ev: FormEvent<HTMLFormElement>) => {
    ev.preventDefault()

    const enteredAddress = parseInt((ev.target as any)[0].value, 16)
    onAddressEntered?.(enteredAddress)
  }

  return (
    <form onSubmit={onSubmit}>
      <AddressInput />
    </form>
  )
}

export default AddressInput
