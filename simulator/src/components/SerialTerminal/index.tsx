import React, { useEffect, useRef, useState } from 'react'
import styled from 'styled-components'
import { BorderColor, PanelBackground } from '../../styles'
import { useUartRecieve } from '../../hooks'

const OuterContainer = styled.div`
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  padding: 5px;
  background-color: ${PanelBackground};
`

const OutputArea = styled.div`
  overflow-y: scroll;
  font-family: 'Fantasque Sans Mono', Consolas, 'Courier New', monospace;
  flex: 1;
  white-space: pre-wrap;
`

const Input = styled.textarea`
  background-color: transparent;
  color: white;
  border-color: ${BorderColor};
  outline-color: white;
  outline-width: 0.5px;
`

const useSerialBuffer = () => {
  const [serialBuffer, setSerialBuffer] = useState('')
  const recievedCharacter = useUartRecieve()

  useEffect(() => {
    console.log('recieved', recievedCharacter)
    if (!recievedCharacter) return

    // let ascii = '';
    // if(recievedCharacter.value === 13) {
    //     ascii
    // }

    setSerialBuffer(
      prev => `${prev}${String.fromCharCode(recievedCharacter.value)}`
    )
  }, [recievedCharacter])

  return serialBuffer
}

const SerialTerminal: React.FunctionComponent = () => {
  const [inputData, setInputData] = useState('')
  const outputAreaRef = useRef<HTMLDivElement>(null)
  const serialBuffer = useSerialBuffer()

  useEffect(() => {
    outputAreaRef.current?.scrollTo(0, outputAreaRef.current.scrollHeight)
  }, [serialBuffer])

  const onKeyPress = (e: KeyboardEvent) => {
    if (e.code === 'Enter') {
      e.preventDefault()
      e.stopPropagation()

      for (let i = 0; i < inputData.length; i++) {
        window.Main.uartTransmit(inputData.charCodeAt(i))
      }

      setInputData('')
    }
  }

  return (
    <OuterContainer>
      <OutputArea ref={outputAreaRef}>{serialBuffer}</OutputArea>
      <Input
        value={inputData}
        onChange={x => setInputData(x.target.value)}
        onKeyPress={onKeyPress}
      />
    </OuterContainer>
  )
}

export default SerialTerminal
