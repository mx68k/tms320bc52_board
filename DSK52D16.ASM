;
; File: DSK52D16.ASM -> Communications kernel program for 320C52 /  8. May. 2023
;
; Requires coff assembler version 6.40 to assemble!
;
ESC      .set     01bh        ; escape
         .width   100
         .length   55
         .title "TMS320C52 Debugger Kernal"
         .version 50
         .mmregs
VERSION  .set 0001h    ; -> .01 version

         .def tmp1,PREGH,PREGL,ST1,BITLEN,BITLEN2,ST0
         .def startadd,scratch,TREG,STACK,AUXREG,ACCUH
         .def ACCUL,length,STATUS,INTER,len,TIMER
         .def main,start,execmd,lddm,ldpm,ldld,ldlp,exec
         .def getdata,special,address,xmtwrd
         .def trapx,ACCBL,ACCBH
;
;        .bss section: be careful with some predefined addresses !!!!!
;
         .bss ACCUL,1         ; add=60h
         .bss ACCUH,1         ; add=61h
         .bss ACCBL,1         ; add=62h
         .bss ACCBH,1         ; add=63h
         .bss PREGL,1         ; add=64h
         .bss PREGH,1         ; add=65h
         .bss ST0,1           ; add=66h
         .bss ST1,1           ; add=67h
         .bss TREG,1          ; add=68h
         .bss STACK,8         ; add=69h
         .bss AUXREG,3        ; add=71h
         .bss TIMER,1         ; add=74h
         .bss KPDWSR,1        ; add=75h
         .bss KCWSR,1         ; add=76h
         .bss KBRCR,1         ; add=77h
         .bss BITLEN2,1       ; add=78h -\
         .bss BITLEN,1        ; add=79h   \  -> used for Baudrate
         .bss scratch,1       ; add=7ah    \
         .bss tmp1,1          ; add=7bh     \ reserved for debugger kernel
         .bss startadd,1      ; add=7ch     /
         .bss length,1        ; add=7dh    /
         .bss STATUS,1        ; add=7eh   /
         .bss INTER,1         ; add=7fh -/

;----------------------------------------------------------------------
; GETCMD: receive 'get' command -> returns 'command' in ar0 and arp=ar0
;----------------------------------------------------------------------
GETCMD  .macro
         call  reads          ; receive a byte --> command
         sacl  scratch        ; save it for retransmit
         call  xmtbyte,ar5    ; send back program end address,returns arp=6
         lar   ar5,scratch    ; return cmd in ar6
         .endm
;----------------------------------------------------------------------
; DPM: Display Program Memory: transmit data block from C26 to HOST
;----------------------------------------------------------------------
DPM      .macro
         call address         ; returns ar6=startadd,ar7=length,arp->ar6
loop?    lacc startadd        ; start add
         tblr tmp1            ; get 'n.' word from pgm to data
         add  #1              ; increment pointer: accu++
         sacl startadd        ; save pointer (accu)
         lacc tmp1            ; prepare for transmit
         call xmtwrd          ; transmit value in ACCU to PC
         mar  *,ar7           ; arp=ar7
         banz loop?,*-        ; repeat for all words
         ret
         .endm
;----------------------------------------------------------------------
; DDM: Display (dump) Data Memory: transfer several words from DSP to PC
;----------------------------------------------------------------------
DDM      .macro
         call address         ; returns ar6=startadd,ar7=length,arp->ar6
         mar  *,AR6
loop?    lacc *+
         call xmtwrd          ; transmit value in ACCU to PC
         mar  *,ar7
         banz loop?,*-,ar6
         ret
         .endm
;----------------------------------------------------------------------
; DLD: download data memory (from PC to 320C26)
;----------------------------------------------------------------------
DLD      .macro
         call address         ; returns ar6=startadd,ar7=length,arp->ar6
loop?    call getdata
         mar  *,ar6
         sacl *+,ar7
         banz loop?,*-
         ret
         .endm
;----------------------------------------------------------------------
; DLP: download program memory (from PC to 320C26)
;----------------------------------------------------------------------
DLP      .macro
         call address         ; returns ar6=startadd,ar7=length,arp->ar6
loop?    call getdata         ; received word is in 'tmp1'
         lacc startadd
         tblw tmp1
         add  #1              ; akku++
         sacl startadd
         mar  *,ar7
         banz loop?,*-
         ret
         .endm
;----------------------------------------------------------------------
; DMPREG: dump register: context save of all registers to internal RAM B2
;----------------------------------------------------------------------
DMPREG   .macro
          sst    #0,ST0        ; save status register 0
          dint                 ; avoid double interrupts!!!!
          ldp    #ST0          ; load data page pointer to page 0
trapx:    sacl   ACCUL         ; save accu low
          sst    #1,ST1        ; save status register 1
          sach   ACCUH         ; save accu high
          lacc   tim           ; load actual content of timer register
          sacl   TIMER         ; copy timer to B2
          lacb                 ; ACCB -> ACC
          sacl   ACCBL         ; save accb low
          sach   ACCBH         ; save accb hugh
          sph    PREGH         ; save product register high
          spl    PREGL         ; save product register low
          mpy    #1            ; treg -> preg
          spl    TREG          ; save T-Register
          sar    ar5,AUXREG    ; save ar5
          sar    ar6,AUXREG+1  ; save ar6
          sar    ar7,AUXREG+2  ; save ar7
          larp   ar5           ; arp=ar5
          lark   ar5,#STACK    ; ar5-> stack / force 8 bit constant
          rpt    #7            ; save 8 stack register
          popd   *+            ; stack -> memory
;
; the following is necessary to rebuilt the ARP for the display!
; while keeping all the other bits unchanged (especially Data page pointer)!
;
          ldp    #ST0          ; go back to page 0 !!!! added: 14.7.92
          lst    #1,ST1
          lst    #0,ST0
;         ldp    ST0           ; added to correct DP problem: 14.7.92
          sst    #0,ST0
          ldp    #ST0          ; added to correct DP problem: 14.7.92
          .endm
;----------------------------------------------------------------------
;  EXECUTE:   execute a program from address !
;----------------------------------------------------------------------
EXECUTE  .macro
         call   getdata       ; received word is in accu and 'tmp1'-->startadd
         sacl   STACK         ; startadd= address for restart of user program
         bcnd   $+4,bio       ; wait for start code
         b      $-2
         bcnd   $,bio
; the following lines execute a dummy interrupt to reset IF(int2) !!!!!
         lack   1             ; flag into 'scratch' for 'halt'
         bldd   #66h,tmp1     ; save B2(ST0) to temp
         eint                 ; execute the interrupt service routine
         sacl   scratch       ; set a flag for executing dummy interrupts
         bldd   tmp1,#66h     ; restore ST0 to B2(ST0)
; IFR(int2) is turned off!
         lacl   #0            ; reset flag
         sacl   scratch       ; in scratch!
; finished dummy interrupt!!!!!!!
         lar    ar5,#STACK+7  ; force 8 bit constant
         rpt    #7            ; reload stack (6 values)
         pshd   *-
         lar    ar5,AUXREG
         lar    ar6,AUXREG+1
         lar    ar7,AUXREG+2
         lt     PREGL
         mpy    #1
         lph    PREGH
         lt     TREG
         lacc   TIMER
         sacl   tim
         lacc   ACCBH,16
         adds   ACCBL
         sacb
         lacc   ACCUH,16
         adds   ACCUL
         lst    #1,ST1
         lst    #0,ST0
         eint
         ret
         .endm
;----------------------------------------------------------------------
;  TRANSMIT: transmit word
;----------------------------------------------------------------------
TRANSMIT .macro
xmtwrd   sacl scratch
         rpt  #7
         sfr
         call _xmtbyte         ; send highbyte
         lacc scratch         ;
_xmtbyte bcnd $+4,bio         ; expect a sync (0) signal from PC
         b    $-2
; xmtbyte follows now         ; send lowbyte and return to calling pgm
;
;  'xmtbyte' requires ARP->AR0 and sets ACCU='mask for byte'
;  send startbit (0) +  databyte + stopbits (2)
;
xmtbyte: clrc c               ; startbit=0
         lar  ar5,#8          ; counter: 1 startbit+ 8 databits (+ 2 stopbits)
nextbit1 bcnd snd0,nc         ; if c=1 send 1 else send 0
snd1     setc xf              ; send one
         b    snd
snd0     clrc xf
snd      rpt  BITLEN          ; send one bit
         mar  *,ar5
         ror                  ; lsb(accu) -> carrybit
         banz nextbit1,*-     ; repeat for entire word (10 bits)
;    
         setc xf
         rpt  BITLEN
         nop
         rpt  BITLEN
         nop
         ret
         .endm
;----------------------------------------------------------------------
; GETADD:   receive startaddress and length
;           return: ar6=startadd / ar7=len / arp= ar6
;----------------------------------------------------------------------
GETADD   .macro
address  call   getdata       ; receive start address and send it back!!!!
         sacl   startadd
         lar    ar6,startadd  ; len   add
         call   getdata       ; receive length and send it back!!!!
         sacl   length        ; length includes the zero!!!
         lar    ar7,length    ; len   add
         larp   ar6
         ret
         .endm
;----------------------------------------------------------------------
; GETDATA: receive a word and send it back
;          ACCU and tmp1 returns received word
;          uses 'tmp1'
;----------------------------------------------------------------------
GETDATA  .macro
getdata  call   reads         ; receive low byte of word
         sacl   tmp1          ; save low byte
         call   xmtbyte       ; send it back
         call   reads         ; receive high byte of word
         add    tmp1,8
         sacl   tmp1
         call   xmtbyte       ; send it back
         lacc   tmp1
         ret
         .endm
;----------------------------------------------------------------------
; Exchange program memory address
; 1. receive pgm address
; 2. read    content address and send content to PC
; 3. receive new content and store it
;----------------------------------------------------------------------
XCH_PGM  .macro
         call address         ; returns ar6=startadd,ar7=length,arp->ar6
         lacc startadd        ; startadd==address
         tblr startadd        ; startadd:=original content of address
         tblw length          ; length== new content
         lacc startadd
         b    xmtwrd          ; transmit value in ACCU to PC
         .endm
;----------------------------------------------------------------------
; the following macro is a software halt (like a NMI) to halt (stop) the
; 320C26 while in runmode
;----------------------------------------------------------------------
HALT     .macro
halt:    ldp    #ST0          ; load dta page pointer to 0
         bit    scratch,15    ; TC=1 => dummy interrupt
         bcnd   trapx,ntc  ; if bit==0 it is a HALT => go to trapx routine
         reti                 ; return from dummy interrupt
         .endm
;----------------------------------------------------------------------
; READS: read serial mode
;----------------------------------------------------------------------
READS     .macro
reads:    rpt    BITLEN
          nop
wait      Bcndd  STOK,bio     ;wait for start bit
          lar    AR5,#7
          lacl   #0
          B      wait         ;
STOK      rpt    BITLEN2      ;BITLEN is scaled and
          nop
          mar    *,AR5        ;number of bits - 1
WTBIT     sfr
          rpt    BITLEN       ;decremented by 8/3 for
          nop                 ;BITLEN/2 wait
          bcnd   ZEROBT,bio
          add    #80h
ZEROBT    BANZ   WTBIT,*-     ;last bit ?
	  RET		      ;ACC = read value
          .endm
;======================================================================
;
;  BEGIN OF MAIN PROGRAM
;
;======================================================================
         .text
         b       start        ;00; RESET
int1     rete                 ;02; vectors for interrupt int1
         nop
int2     b       halt         ;04; vectors for interrupt int2
int3     rete                 ;06; vectors for interrupt int3
         nop
tint     rete                 ;08; timer interrupt vector - TINT
         nop
rint     rete                 ;0A; Serial port receive interrupt
         nop
xint     rete                 ;0C; Serial port transmit interrupt
         nop
         .space  4 * 16       ;0E; vectors for TDM port TRNT, TXNT
int4     b       start        ;12; vectors for interrupt int4
         .space  14 * 16      ;14; Reserved space.  Should not be used.
         b       trap         ;22; trapx instruction vector
         .space  2 * 16       ;24; Non Maskable Interrupt vector
         .space  2 * 16       ;26; Reserved space.  Should not be used.
         .space 24 * 16       ;28; Software Interrupt.

         .word   special
         .word   len,VERSION
start:   ldp    #0
         clrc   SXM
         ;opl    #0834h,PMST    ; set 9K on-chip RAM both prog & data memory
         lacc   #0             ; set Wait State Control Register
         sacl   CWSR           ; for 0 waits in prog & data memory
         sacl   PDWSR
		 setc   CNF            ; The on-chip DARAM block 0 is mapped into program memory space.
         lar    AR5,#0         ; using AR5 to count bit langth
         mar    *,AR5
;        bcnd   $,bio          ; prevent to hit the bio at the middle.
autob0   bcnd   stbit,bio      ; wait for start bit
         b      autob0
stbit    bcndd  stbit,bio      ; send in 0x80 will keep 8 bit length low
         mar    *+,AR5         ;
         mar    *+,AR5         ;
;         lacc   AR5,12         ;
		 lacc   AR5,12         ;
         sach   BITLEN2        ; save AR5/16 in BITLEN2
;         lacc   AR5,14
		 lacc   AR5,14
;        sub    #10h,15
         sach   BITLEN         ; save AR5/8 in BITLEN

XMT_ESC  lacc   #ESC           ; send ESC to PC
         call   xmtbyte

main     call   execmd         ; 'main control loop	 
         b      main           ; execmd returns here after command execution
;
; execute commands
;

execmd   GETCMD               ; macro returns command in ar0 and arp=ar0
lddm     banz   ldpm,*-       ; dump data memory
         DDM                  ; macro 'dump data memory'    DSP -> PC
ldpm     banz   ldld,*-       ; dump program memory
         DPM                  ; macro 'dump program memory' DSP -> PC
ldld     banz   ldlp,*-       ; load data memory to c26
         DLD                  ; macro 'download data'       PC  -> DSP
ldlp     banz   xpgm,*-       ; load program memory to c26
         DLP                  ; macro 'download program'    PC  -> DSP
xpgm     banz   exec,*-       ; load pgm  word to PC
         XCH_PGM              ; macro 'exchange pgm memory word'
exec     banz   special,*-    ; execute to breakpoint or single step
         EXECUTE              ; macro 'execute program'
         GETDATA              ; macro 'get data word'
         GETADD               ; macro 'get 2 data words'
         TRANSMIT             ; macro 'transmit a word or a byte'
         READS                ; macro 'serial RS232 mode from BIO-PIN'
trap     DMPREG
         b      XMT_ESC       ; send ESC to synchronize DSP & PC
special  ret                  ; branch back if invalid 'code'
         HALT                 ; Interrupt (2) service routine
                              ; HALT gets overwritten from some copy/fill progs
len      .set    $-00000h     ; length of monitor kernal
         .end
