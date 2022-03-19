import React from 'react'
import useCanvas from './useCanvas'

const GraphicDisplay: React.FunctionComponent = () => {
  const canvasRef = useCanvas((ctx, frameCount) => {
    ctx.fillStyle = 'green'
    ctx.fillRect(0, 0, 640, 480)

    ctx.fillStyle = 'red'
    ctx.fillRect(120, 120, 200, 200)
  })

  return <canvas ref={canvasRef} width="640" height="480" />
}

export default GraphicDisplay
