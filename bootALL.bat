del *.hex
DSPA -ls -V50 DSK52D16.ASM
DSPLNK DSK52D16.CMD
dsphex B16_H8.CMD
ren DSK52D16.I0 DSK52D16.HEX
dsphex BOOT16.CMD
ren DSK52D16.LSB B16LSB.HEX
ren DSK52D16.MSB B16MSB.HEX
dsphex B16_H16.CMD
ren DSK52D16.LSB BH16LSB.HEX
ren DSK52D16.MSB BH16MSB.HEX