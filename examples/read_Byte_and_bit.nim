import picostdlib/[stdio, gpio, time, i2c]
import pcf8575
from strutils import tobin

# -- settings for I2c ------------
# Example: p0=Low, p1=High, p2=High
stdioInitAll()
sleep(1500)

let expander = newExpander16(blokk = i2c1, expAddr = 0x20)
const 
  sda = 2.Gpio
  scl = 3.Gpio
init(i2c1,50_000)
sda.setFunction(I2C); sda.disablePulls()
scl.setFunction(I2C); scl.disablePulls()

print("Read 2 Bytes of pcf8587")
print("-----------------------")
let readPcfByte: uint16 = expander.readBytes()
print("Read in decimal --> " & $readPcfByte)
print("Read in decimal --> " & $int(readPcfByte).toBin(16))

#[
Read 2 Bytes of pcf8587
-----------------------
Read in decimal --> 6
Read in decimal --> 0000000000000110 (p0=LSB)
]#
print("Now read ONLY p1")
let readPcfbit = expander.readBit(p1)
print("p1 value --> " & $readPcfbit)

#[
Now read ONLY p1
p1 value --> true
]#
