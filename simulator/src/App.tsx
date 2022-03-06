import DebugPanel from './components/DebugPanel'
import Layout from './components/Layout'
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
    </>
  )
}
