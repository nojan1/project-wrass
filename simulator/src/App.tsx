import BlinkenLights from './components/BlinkenLights'
import DebugPanel from './components/DebugPanel'
import LastTrap from './components/LastTrap'
import Layout from './components/Layout'
import OutputPanel from './components/OutputPanel'
import KeyboardEventHandler from './components/KeyboardEventHandler'
import { MachineContextProvider } from './context/machine'
import { GlobalStyle } from './styles/GlobalStyle'

export function App() {
  return (
    <MachineContextProvider>
      <KeyboardEventHandler />
      <GlobalStyle />
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
    </MachineContextProvider>
  )
}
