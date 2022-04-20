/* eslint-disable no-unused-vars */

export enum R1Flags {
  Success = 0,
  InIdleState = 1,
  EreaseReset = 2,
  IllegalCommand = 4,
  CrcError = 8,
  EreaseSequenceError = 16,
  AddressError = 32,
  ParameterError = 64,
}

export enum SdSpiCommands {
  // GO_IDLE_STATE
  CMD0 = 0,

  // SEND_OP_COND
  CMD1 = 1,

  // APP_SEND_OP_COND
  ACMD41 = 41,

  // SEND_IF_COND
  CMD8 = 8,

  // SEND_CSD
  CMD9 = 9,

  // SEND_CID
  CMD10 = 10,

  // STOP_TRANSMISSION
  CMD12 = 12,

  // SET_BLOCKLEN
  CMD16 = 16,

  // READ_SINGLE_BLOCK
  CMD17 = 17,

  // READ_MULTIPLE_BLOCK
  CMD18 = 18,

  // SET_BLOCK_COUNT
  CMD23 = 23,

  // WRITE_BLOCK
  CMD24 = 24,

  // WRITE_MULTIPLE_BLOCK
  CMD25 = 25,

  // APP_CMD
  CMD55 = 55,

  // READ_OCR
  CMD5 = 5,
}
