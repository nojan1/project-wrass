import React, { useCallback, useEffect, useState } from 'react'

export const useFitToParent = (
  ref: React.RefObject<HTMLCanvasElement>,
  baseWidth: number,
  baseHeight: number,
  margin: number = 0
) => {
  const [width, setWidth] = useState<number>()
  const [height, setHeight] = useState<number>()

  const onResize = useCallback(() => {
    if (!ref?.current?.parentElement) return

    const parentHeight = ref.current.parentElement?.clientHeight
    const parentWidth = ref.current.parentElement?.clientWidth

    let newWidth = parentWidth - 2 * margin
    let newHeight = newWidth / (baseWidth / baseHeight)

    if (newHeight > parentHeight - 2 * margin) {
      newHeight = parentHeight - 2 * margin
      newWidth = newHeight * (baseWidth / baseHeight)
    }

    setWidth(newWidth)
    setHeight(newHeight)
  }, [ref, baseWidth, baseHeight, margin, setWidth, setHeight])

  useEffect(() => {
    onResize()
    window.addEventListener('resize', onResize)

    return () => {
      window.removeEventListener('resize', onResize)
    }
  }, [onResize])

  return { width, height }
}
