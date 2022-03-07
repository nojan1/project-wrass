const I_LDA = 0xa9
const I_STA = 0x8d
const I_JMP = 0x4c

const program = [
  I_LDA,
  0x55, // lda 55
  I_STA,
  0x00,
  0x60, // 55 -> 6000 (output 55 to address 0x6000)

  I_LDA,
  0xaa, // lda AA
  I_STA,
  0x00,
  0x60, // AA -> 6000 (output AA to address 0x6000)

  I_JMP,
  0x00,
  0x02, // jump back to start of program
]

export const getTestProgramBuffer = () => Buffer.from(program)
