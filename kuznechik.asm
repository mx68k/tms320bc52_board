;==========================================================================;
;=INFORMATION           PROGRAM         ; kuznechik                       =;
;=============          FILE NAME       ; kuznechik.asm                   =;
;=                      INCLUDE FILES   ; no include files                =;
;=                      PROCESSOR       ; TMS320BC52                      =;
;=                      AUTHOR          ; mx                              =;
;=                      DATE/VERSION    ; May 2023 / Ver 1.00             =;
;==========================================================================;
;=DESCRIPTION                                                             =;
;=============                                                            =;
;=                                                                        =;
;= kuznechik:   A program that initialises the TMS320BC52 DSK processor   =;
;=              send pulses to XF pin and play music                      =;
;=                                                                        =;
;=                                                                        =;
;==========================================================================;
	.mmregs
;==========================================================================;
;=SETTINGS                                                                =;
;==========================================================================;
;==========================================================================;
;=PROCESSOR INITIALISATION                                                =;
;==========================================================================;
	.ds     0fff0h             ; Assemble to data memory
	.data
time0      .word   11111       ;
time1      .word   22222       ;
time_p     .word   33333       ; 
time_p1    .word   44444       ; 
time_p2    .word   55555       ;

	.ps 0FE00h                 ; Assemble to program memory
	.entry                     ; Mark program entry point
	.text                      ; Text
START   setc    INTM           ; Disable interrupts
	    ldp     #0             ; Set data page pointer to page zero
	    lacc    #0             ; Load accumulator with number zero
	    samm    CWSR           ; Set software wait state to zero
	    samm    PDWSR          ; Set software wait state to zero	
;==========================================================================;
;=MAIN PROGRAM                                                            =;
;==========================================================================;
		splk    #700,time0
		splk    #200,time1
		splk    #300,time_p
		splk    #1200,time_p1
		splk    #200,time_p2
		call    timer_on	 
WAIT   
;==========================================================================;
		call    pulse 
		call    delay
		call    pause
		call    pulse	
;==========================================================================;		
		call    nota_f 	
                call    delay			
		call    pause		
		
		call    nota_c 	
                call    delay
		call     		
			
		call    nota_f 	
                call    delay				
		call    pause		
			
		call    nota_c 	  
                call    delay					
		call    pause		
		
		call    nota_f 	
                call    delay		
		call    pause		
			
		call    nota_e 	
                call    delay				
		call    pause		
			
		call    nota_e 	  
                call    delay				
		call    pause_1	
;==========================================================================;			
		call    nota_e 	
                call    delay
		call    pause		
				
		call    nota_c 	
                call    delay				
		call    pause		
				
		call    nota_e 		   
                call    delay					
		call    pause		
			
		call    nota_c 	
                call    delay		
		call    pause		
				
		call    nota_e 	
		call    delay		
		call    pause	
		
		call    nota_f 	
		call    delay		
		call    pause	
		
		call    nota_f 	
		call    delay		
		call    pause_1			
;==========================================================================;
		call    nota_f 	
                call    delay		
		call    pause		
				
		call    nota_c 	
                call    delay				
		call    pause		
				
		call    nota_f 		   
                call    delay					
		call    pause		
			
		call    nota_c 	
                call    delay		
		call    pause		
				
		call    nota_f 	
		call    delay		
		call    pause	
		
		call    nota_e 	
		call    delay		
		call    pause	
		
		call    nota_e 	
		call    delay		
		call    pause_1	
;==========================================================================;
		call    nota_e 	
                call    delay		
		call    pause		
				
		call    nota_c 	
                call    delay				
		call    pause		
				
		call    nota_e 		   
                call    delay					
		call    pause		
			
		call    nota_c 	
                call    delay		
		call    pause		
				
		call    nota_e 	
		call    delay		
		call    pause	
		
		call    nota_f 	
		call    delay		
		call    pause_1	
		call    pause_1		
;==========================================================================;
;==========================================================================;
		call    nota_f 	
                call    delay		
		call    pause		
				
		call    nota_g 	
                call    delay				
		call    pause		
				
		call    nota_g 		   
                call    delay_1					
		call    pause_2		
			
		call    nota_g 	
                call    delay_1		
		call    pause_2		
				
		call    nota_g 	
		call    delay		
		call    pause	
		
		call    nota_g 	
		call    delay		
		call    pause	
		
		call    nota_gd 	
		call    delay		
		call    pause		
		
		call    nota_gd 	
		call    delay_1		
		call    pause_2	
		
		call    nota_gd 	
		call    delay_1		
		call    pause_2	
		
		call    nota_gd 	
		call    delay		
		call    pause		
;==========================================================================;
		call    nota_gd 	
                call    delay		
		call    pause		
				
		call    nota_gd	
                call    delay				
		call    pause		
				
		call    nota_g 		   
                call    delay					
		call    pause		
			
		call    nota_f 	
                call    delay		
		call    pause		
				
		call    nota_e 	
		call    delay		
		call    pause	
		
		call    nota_f 	
		call    delay		
		call    pause			
		
		call    nota_f 	
		call    delay		
		call    pause_1	
;==========================================================================;
		call    nota_f 	
                call    delay		
		call    pause		
				
		call    nota_g 	
                call    delay				
		call    pause		
				
		call    nota_g 		   
                call    delay_1					
		call    pause_2		
			
		call    nota_g 	
                call    delay_1		
		call    pause_2		
				
		call    nota_g 	
		call    delay		
		call    pause	
		
		call    nota_g 	
		call    delay		
		call    pause	
		
		call    nota_gd 	
		call    delay		
		call    pause		
		
		call    nota_gd 	
		call    delay_1		
		call    pause_2	
		
		call    nota_gd 	
		call    delay_1		
		call    pause_2	
		
		call    nota_gd 	
		call    delay		
		call    pause	
;==========================================================================;
		call    nota_gd 	
                call    delay		
		call    pause		
				
		call    nota_gd 	
                call    delay				
		call    pause		
				
		call    nota_g 		   
                call    delay					
		call    pause		
			
		call    nota_f 	
                call    delay		
		call    pause		
				
		call    nota_e 	
		call    delay		
		call    pause	
		
		call    nota_f 	
		call    delay				
		call    pause_1			
;==========================================================================;
                b       WAIT           ; Branch to WAIT

pulse   setc    xf
		call    delay
		clrc    xf
		call    delay	
		ret
		 
delay	rpt     0ffffh         ; 
		nop                    ; No operation
		banz    delay,ar5      ; 
		lar     ar5,time0      ; 
                ret
		
delay_1	rpt     0ffffh         ; 
		nop                    ; No operation
		banz    delay_1,ar6    ; 
		lar     ar6,time1      ; 
                ret

timer_on
		splk    #2Fh,TCR       ; reload and start timer
		ret

timer_off
		splk    #10h,TCR       ; stop timer
		ret
		
pause	splk    14,PRD         ; Load period counter
		rpt     0ffffh         ; 
		nop                    ; No operation
		banz    pause,ar3      ; 
		lar     ar3,time_p     ; 
                ret
		
pause_1	splk    14,PRD         ; Load period counter
		rpt     0ffffh         ; 
		nop                    ; No operation
		banz    pause_1,ar4    ; 
		lar     ar4,time_p1    ;
                ret		
		
pause_2	splk    14,PRD         ; Load period counter
		rpt     0ffffh         ; 
		nop                    ; No operation
		banz    pause_2,ar7    ; 
		lar     ar7,time_p2    ; 
                ret				
				
nota_c
		splk    2388,PRD       ; do 261.63 Hz Load period counter
		ret
		
nota_cd
		splk    2254,PRD       ; do # 277.18 Hz Load period counter
		ret	
		
nota_d
		splk    2127,PRD       ; re 293.66 Hz Load period counter
		ret		
		
nota_dd
		splk    2008,PRD       ; re # 311.13 Hz Load period counter
		ret		
		
nota_e
		splk    1895,PRD       ; mi 329.63 Hz Load period counter
		ret
		
nota_f
		splk    1789,PRD       ; fa 349.23 Hz Load period counter
		ret	
		
nota_fd
		splk    1688,PRD       ; fa # 369.99 HzLoad period counter
		ret		
		
nota_g
		splk    1593,PRD       ; col 392 Hz Load period counter
		ret		

nota_gd
		splk    1504,PRD       ; col # 415.3 Hz  Load period counter
		ret
		
nota_a
		splk    1419,PRD       ; lya 440 Hz Load period counter
		ret	
		
nota_bb
		splk    1340,PRD       ; lya # 466.16 Hz Load period counter
		ret		
		
nota_b
		splk    1264,PRD       ; si 493.88 Hz Load period counter
		ret				
		
;==========================================================================;                      
	.end                       ; End of program
