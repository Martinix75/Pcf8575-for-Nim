import picostdlib/[stdio, gpio, time, i2c]
import pcf8575l
#from strutils import tobin

# -- settings for I2c ------------
# Example: set p0=1, p1=0, p2=1
stdioInitAll()
sleep(1500)

let expander = newExpander16(blokk = i2c1, expAddr = 0x20)
const 
  sda = 2.Gpio
  scl = 3.Gpio
init(i2c1,50_000)
sda.setFunction(I2C); sda.disablePulls()
scl.setFunction(I2C); scl.disablePulls()

print("Write 2 Bytes of pcf8587")
print("-----------------------")
print("Now all LOW")
expander.setLow()
sleep(2000)
print("On p0 & p2")
expander.writeBytes(5)
sleep(2000)
print("Off ONLY p2")
expander.writeBit(p2, on)
sleep(2000)
print("Now all HIGH")
expander.setHigh()
