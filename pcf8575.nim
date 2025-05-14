#[
Driver for 16bit expander Pcf8575 write in Nim.
The MIT License (MIT)
Copyright (c) 2023 Martin Andrea (Martinix75)
testet with Nim 2.0.0

author Andrea Martin (Martinix75)
https://github.com/Martinix75/Pcf8575-for-Nim
]#

import picostdlib
import picostdlib/pico/[stdio, time]
import picostdlib/hardware/[gpio, i2c]
from math import log2

const 
  pcf8575Ver* = "2.0.0" # for picoStdLib >= 0.4.0
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
  Pcf8575 = object #creata the Pcf8575 object ver 2.0.0 no REF.
    expAddr: uint8
    blokk: ptr I2cInst
    data: uint16 = 0x0000
    buffer: array[0..1, byte] #!! i2c scrive 8 bit (1 byte) alal volta!!

proc makeBuffer(self: var Pcf8575) =
  let byteHigh: byte = byte(self.data shr 8)
  let byteLow: byte = byte(self.data and 0xFF)
  self.buffer[0] = byteLow #write low byte in frist position.
  self.buffer[1] = byteHigh #write high byte in second position.

proc makeData(self: var Pcf8575) =
  self.data = uint16(self.buffer[1]) shl 8 #byte alto si spostadi 8 bit in avti.
  self.data = self.data or self.buffer[0] #byte basso nei primi 8 bit.

proc writeBytes*(self: var Pcf8575; data: uint16; inverse: bool = true) = #modified ver 2.0.0
  if inverse == true: #invereti perche è opencolector ed i numeri  (0=1, e 1=0)
    self.data = not data
  else:
    self.data = data
  self.makeBuffer()
  let addrArray = self.buffer[0].unsafeAddr
  discard writeBlocking(self.blokk, self.expAddr.I2cAddress, addrArray, 2, false)
  
proc writeBit*(self: var Pcf8575; pin: uint16; value: bool) =
  if value == on:
    self.data = not self.data or pin #data è stata invertita tocca reivertire ogni volta!
    self.writeBytes(data = self.data)
  elif value == off:
    let ctrl:uint16  = not self.data shr uint16(log2(float(pin))) #muove il bit scelto in posizione 1
    if (ctrl mod 2) != 0: #se è dispari (ovvero alto) applica lo xor altriment è zero e non occore fare nulla.
      self.data = not self.data xor pin
      self.writeBytes(data = self.data)

proc readBytes*(self: var Pcf8575): uint16 =
  self.buffer[0] = 0; self.buffer[1] = 0
  let addrArray = self.buffer[0].unsafeAddr
  discard readBlocking(self.blokk, self.expAddr.I2cAddress, addrArray, 2, false)
  self.makedata()
  result = self.data
  
proc readBit*(self: var Pcf8575; pin: uint16): bool =
  let bitValue: uint16 = self.readBytes()
  result = bool(bitValue and pin)
  
  
proc setLow*(self: var Pcf8575) =
  self.data = 0x0000
  self.writeBytes(data = self.data)

proc setHigh*(self: var Pcf8575) =
  self.data = 0xFFFF
  self.writeBytes(data = self.data)

proc initExpander16*(blokk: ptr I2cInst; expAddr: uint8 = 0x20): Pcf8575 =
  result = Pcf8575(blokk: blokk, expAddr: expAddr)
  # da valutare se inizializzare i pin i2c qui.. ma forse no meglio indipendente
  
when isMainModule:
  stdioInitAll()
  sleepMs(1500)
  print("Partenza....")
  var expander = initExpander16(blokk = i2c1, expAddr = 0x20)
  const 
    sda = 2.Gpio
    scl = 3.Gpio
  discard init(i2c1,50_000)
  sda.setFunction(I2C); sda.disablePulls()
  scl.setFunction(I2C); scl.disablePulls()
  let timeSl: uint32 = 200
  var supercar: uint16 = 0x01
  while true:
    for _ in countUp(0, 14):
      expander.writeBytes(supercar)
      supercar = supercar shl 1
      sleepMs(timeSl)
    for _ in countUp(0, 14):
      expander.writeBytes(supercar)
      supercar = supercar shr 1
      sleepMs(timeSl)
    #[print("Spengo tutto...")
    expander.setLow()
    sleep(2000)
    print("Accendo led p2 & p1..")
    expander.writeBytes(0x0006) #1 byte ttto 1
    sleep(2500)
    print("Accendo Led (p2 & p1) + p0")
    expander.writeBit(p0, on)
    sleep(2500)
    print("Spengo P2...")
    expander.writeBit(p2, off)
    sleep(2000)
    print("-------------")
    print("Ora provo a leggere il bit 0......")
    let lettura = expander.readBit(p0)
    print("Ho letto: " & $lettura)
    sleepMs(2000) ]#

