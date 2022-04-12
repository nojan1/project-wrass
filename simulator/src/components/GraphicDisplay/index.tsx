import React, { useMemo } from 'react'
import { useFramebuffer } from '../../hooks'
import useCanvas from './useCanvas'

const GraphicDisplay: React.FunctionComponent = () => {
  const framebuffer = useFramebuffer()

  const imageData = useMemo(() => {
    if (!framebuffer) return
    return new ImageData(framebuffer, 640)
  }, [framebuffer])

  const canvasRef = useCanvas((ctx, frameCount) => {
    if (!imageData) return null
    ctx.putImageData(imageData, 0, 0)
  })

  return (
    <canvas
      ref={canvasRef}
      width="640px"
      height="480px"
      // style={{ transform: 'scale(2)' }}
    />
  )
}

export default GraphicDisplay
