import BlinkenLights from './components/BlinkenLights'
import DebugPanel from './components/DebugPanel'
import LastTrap from './components/LastTrap'
import Layout from './components/Layout'
import OutputPanel from './components/OutputPanel'
import KeyboardEventHandler from './components/KeyboardEventHandler'
import { MachineContextProvider } from './context/machine'
import { GlobalStyle } from './styles/GlobalStyle'
import { Route, Routes } from 'react-router'
import SerialTerminal from './components/SerialTerminal'

export function App() {
  console.log('Inside app')
  return (
    <MachineContextProvider>
      <KeyboardEventHandler />
      <GlobalStyle />
      <Routes>
        <Route path="/serialTerminal" element={<SerialTerminal />} />
        <Route
          index
          element={
            <Layout
              footer={
                <>
                  <LastTrap />
                  <BlinkenLights />
                </>
              }
            >
              <OutputPanel />
              <DebugPanel />
            </Layout>
          }
        />
      </Routes>
    </MachineContextProvider>
  )
}
