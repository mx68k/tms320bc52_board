# TMS320BC52 board 

Communications kernel program ROM, serial loader and test program for TMS320BC52 board.

kuznechik.ASM is a program that plays the tune of the song "В траве сидел кузнечик" using timer.

## Pictures

TMS320BC52 board

![TMS320BC52 board](/TMS320BC52_brd.jpg)


TMS320BC52PJ 100-Pin QFP

![TMS320BC52PJ 100-Pin QFP](/TMS320BC52PJ.png)


## Serial loader

~~~
>python dsk_send.py kuznechik.DSK kuznechik.DSK.txt


DSK file : kuznechik.DSK


HEX data from DSK file will be saved to : kuznechik.DSK.txt


line 1 = ...
line 2 = ...
line 3 = ...
...
~~~


##  Board schematics
 
![Board schematics](/TMS320BC52_sch.jpg)
