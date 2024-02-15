import ReactDOM from 'react-dom'
import { App } from './App'
import { HashRouter } from 'react-router-dom'

ReactDOM.render(
  <HashRouter>
    <App />
    {/* <Routes>
      <Route path="/main_window" element={<App />} />
    </Routes> */}
  </HashRouter>,
  document.getElementById('root')
)
