import React from 'react'
import { X } from 'react-feather'
import styled from 'styled-components'
import { BorderColor, PanelBackground } from '../../styles'

export interface ModalProps {
  isOpen: boolean
  onClose?: () => void
}

const ModalBackdrop = styled.div`
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(100, 100, 100, 0.7);
  z-index: 100;
  display: flex;
  justify-content: center;
  align-items: center;
`

const ModalHeaderRow = styled.div`
  display: flex;
  justify-content: end;
  margin-bottom: 5px;
`

const ModalContainer = styled.div`
  border: 1px solid ${BorderColor};
  background-color: ${PanelBackground};
  padding: 5px;
`

const ModalInnerContanier = styled.div`
  padding: 5px;
`

const Modal: React.FunctionComponent<ModalProps> = ({
  isOpen,
  onClose,
  children,
}) => {
  if (!isOpen) return null

  return (
    <ModalBackdrop>
      <ModalContainer>
        {onClose && (
          <ModalHeaderRow>
            <X onClick={() => onClose()} />
          </ModalHeaderRow>
        )}

        <ModalInnerContanier>{children}</ModalInnerContanier>
      </ModalContainer>
    </ModalBackdrop>
  )
}

export default Modal
