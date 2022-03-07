export const toHex = (value: number, length = 4) =>
  `$${value.toString(16).toUpperCase().padEnd(length, '0')}`
