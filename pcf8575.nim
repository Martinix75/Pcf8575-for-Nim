#[
Driver for 16bit expander Pcf8575 write in Nim.
The MIT License (MIT)
Copyright (c) 2023 Martin Andrea (Martinix75)
testet with Nim 2.0.0

author Andrea Martin (Martinix75)
https://github.com/Martinix75/Pcf8575-for-Nim
]#

import picostdlib/[stdio, gpio, time, i2c]
from math import log2

const 
  pcf8575Ver* = "1.0.0" # ripreso dal pfc8574 ad 8 bit.
  p0*: uint16 = 0x0001
  p1*: uint16 = p0 shl 1
  p2*: uint16 = p0 shl 2
  p3*: uint16 = p0 shl 3
  p4*: uint16 = p0 shl 4
  p5*: uint16 = p0 shl 5
  p6*: uint16 = p0 shl 6
  p7*: uint16 = p0 shl 7
  p10*: uint16 = p0 shl 8
  p11*: uint16 = p0 shl 9
  p12*: uint16 = p0 shl 10
  p13*: uint16 = p0 shl 11
  p14*: uint16 = p0 shl 12
  p15*: uint16 = p0 shl 13
  p16*: uint16 = p0 shl 14
  p17*: uint16 = p0 shl 15

type
  Pcf8575 = ref object #creata the Pcf8575 object.
    expAddr: uint8
    blokk: I2cInst
    data: uint16 = 0x0000
    buffer: array[0..1, byte]

proc makeBuffer(self:Pcf8575) =
  let byteHigh: byte = byte(self.data shr 8)
  let byteLow: byte = byte(self.data and 0xFF)
  self.buffer[0] = byteLow #write low byte in frist position.
  self.buffer[1] = byteHigh #write high byte in second position.

proc makeData(self: Pcf8575) =
  self.data = self.buffer[1] shl 8 #byte alto si spostadi 8 bit in avti.
  self.data = self.data or self.buffer[0] #byte basso nei primi 8 bit.
  
proc writeBytes*(self: Pcf8575; data: uint16; inverse: bool = true) =
  if inverse == true: #invereti perche è opencolector ed i numeri  (0=1, e 1=0)
    self.data = not data
  else:
    self.data = data
  self.makeBuffer()
  let addrArray = self.buffer[0].unsafeAddr
  writeBlocking(self.blokk, self.expAddr, addrArray, 2, false)
  
proc writeBit*(self: Pcf8575; pin: uint16; value: bool) =
  if value == on:
    print("PIN: " & $pin)
    self.data = not self.data or pin #data è stata invertita tocca reivertire ogni volta!
    self.writeBytes(data = self.data)
  elif value == off:
    let ctrl:uint16  = not self.data shr uint16(log2(float(pin))) #muove il bit scelto in posizione 1
    if (ctrl mod 2) != 0: #se è dispari (ovvero alto) applica lo xor altriment è zero e non occore fare nulla.
      self.data = not self.data xor pin
      self.writeBytes(data = self.data)

proc readBytes*(self: Pcf8575): uint16 =
  self.buffer[0] = 0; self.buffer[1] = 0
  let addrArray = self.buffer[0].unsafeAddr
  discard readBlocking(self.blokk, self.expAddr, addrArray, 2, false)
  self.makedata()
  result = self.data
  
proc readBit*(self: Pcf8575; pin: uint16): bool =
  let bitValue: uint16 = self.readBytes()
  result = bool(bitValue and pin)
  
  
proc setLow*(self: Pcf8575) =
  self.data = 0x0000
  self.writeBytes(data = self.data)

proc setHigh*(self: Pcf8575) =
  self.data = 0xFFFF
  self.writeBytes(data = self.data)

proc newExpander16*(blokk: I2cInst; expAddr: uint8 = 0x20): Pcf8575 =
  result = Pcf8575(blokk: blokk, expAddr: expAddr)


