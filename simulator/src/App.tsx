import DebugPanel from './components/DebugPanel'
import LastTrap from './components/LastTrap'
import Layout from './components/Layout'
import OutputPanel from './components/OutputPanel'
import { GlobalStyle } from './styles/GlobalStyle'

export function App() {
  return (
    <>
      <GlobalStyle />
      <Layout footer={<LastTrap />}>
        <OutputPanel />
        <DebugPanel />
      </Layout>
    </>
  )
}
