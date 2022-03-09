import { useEffect } from 'react'
import BlinkenLights from './components/BlinkenLights'
import DebugPanel from './components/DebugPanel'
import LastTrap from './components/LastTrap'
import Layout from './components/Layout'
import OutputPanel from './components/OutputPanel'
import { MachineContextProvider } from './context/machine'
import { GlobalStyle } from './styles/GlobalStyle'

export function App() {
  useEffect(() => {
    document.addEventListener('keydown', ev => window.Main.keydown(ev.code))
    document.addEventListener('keyup', ev => window.Main.keyup(ev.code))
  }, [])

  return (
    <MachineContextProvider>
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
