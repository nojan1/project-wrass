import { createGlobalStyle } from 'styled-components'

export const GlobalStyle = createGlobalStyle`
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  body {
    font-size: 16px;
    background-color: black;
    color: white;
    font-family: 'VT323', monospace;
  }

  @font-face {
    font-family: 'VT323';
    font-style: normal;
    font-weight: 400;
    font-display: swap;
    src: url(fonts/VT232.woff2) format('woff2');
    unicode-range: U+0102-0103, U+0110-0111, U+0128-0129, U+0168-0169, U+01A0-01A1, U+01AF-01B0, U+1EA0-1EF9, U+20AB;
  }
`
