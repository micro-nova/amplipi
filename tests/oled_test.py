from amplipi.oled import Display
import time

oled = Display()

i = 0

# demo
while(True):
  # increment
  i = i + 2
  # rollover
  if(i >= 100):
    i = 0
  # set volume bars
  oled.set_volumes([i,i,i,i,i,i])
  # sleep
  time.sleep(1)
