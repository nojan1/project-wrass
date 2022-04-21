import React, { useMemo } from 'react'
import { useFramebuffer } from '../../hooks'
import useCanvas from './useCanvas'
import { useFitToParent } from './useFitToParent'

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

  const { width, height } = useFitToParent(canvasRef, 640, 480, 20)

  return (
    <canvas
      ref={canvasRef}
      width="640px"
      height="480px"
      style={{ width, height }}
    />
  )
}

export default GraphicDisplay
