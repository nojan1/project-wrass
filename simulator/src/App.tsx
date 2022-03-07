import DebugPanel from './components/DebugPanel'
import LastTrap from './components/LastTrap'
import Layout from './components/Layout'
import Footer from './components/Layout/Footer'
import OutputPanel from './components/OutputPanel'
import { GlobalStyle } from './styles/GlobalStyle'

export function App() {
  return (
    <>
      <GlobalStyle />
      <Layout>
        <OutputPanel />
        <DebugPanel />
      </Layout>
      <Footer>
        <LastTrap />
      </Footer>
    </>
  )
}
