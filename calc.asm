INCLUDE library.inc

STACK SEGMENT
     DB 128 DUP(?)
STACK ENDS

DATA SEGMENT
     RESULT  DW 10 DUP(0)
DATA ENDS

CODE SEGMENT
	ASSUME CS:CODE, SS:STACK, DS:DATA
 START:   
     MOV AX, DATA
     MOV DS, AX
     MOV ES, AX

     ;midenismos 4 stoixeiwn tis stoivas
     ;gia tin periptwsi ligoterwn twn 4 ari8mwn
	 MOV AX,0030H
     PUSH AX
     PUSH AX
	 PUSH AX
	 PUSH AX
    ;anagnosi prwtou ari8mou     
     MOV CL, 0    ;ari8mos psifiwn pou diavastikan
  COUNT_READ:    
     CALL CHECKNUM   ;Diavasma enos ari8mou
     CMP AL,0DH
     JZ COUNT_READ  ;no newline allowed so far
     PRINT AL
     CMP AL, '-'
     JNZ NEXT1
     MOV DI, 1    ;energopoihsh flag tou - se 1
     JMP DONE2
  NEXT1:CMP AL, '+'      ; An praksi
     JNZ NEXT2
     MOV DI, 0    ;flag sto 0 an +
     JMP DONE2 
  NEXT2:
     MOV AH, 0
     PUSH AX

     INC CL  
     CMP CL, 4       ; telos an 4 psifia
     JNZ COUNT_READ
 FORCE_OP:
     CALL CHECKNUM            ; Ypoxreotika pra3i an 4 psifia
     CMP AL, '-' 
     JNZ CHECKP    
     MOV DI, 1     ;energopoihsh flag tou - se 1
     JMP NEXT3
  CHECKP:
     CMP AL, '+'
     JNZ FORCE_OP
     MOV DI, 0
 NEXT3:
     PRINT AL
                   
   DONE2:            ; prwtos ari8mos diavastike
     POP AX
     POP CX
     MOV CH,CL
	 MOV CL,0
     OR AX, CX
     CALL THE_TWO    ; metatropi se 8-bit hex
     MOV BL, AL
     POP AX
     POP CX
     MOV CH,CL
	 MOV CL,0
     OR AX, CX   
     CALL THE_TWO
     MOV BH, AL   ; O BX twra exei ton dekae3adiko prwto ari8mo
                
    ;anagnosi deuterou ari8mou            
     MOV AX,0030H
     PUSH AX
     PUSH AX
	 PUSH AX
	 PUSH AX      
     MOV CL, 0    ;ari8mos psifiwn pou diavastikan
 COUNT_READ2: 
     CALL CHECKNUM   ;Diavasma enos ari8mou
     CMP AL,'-'
     JZ COUNT_READ2
     CMP AL,'+'     ;den epitrepontai pra3eis ston deutero ari8mo
     JZ COUNT_READ2
     CMP AL, 0DH      ; elegxos an newline
     JZ DONE3
     PRINT AL 
     MOV AH, 0
     PUSH AX
     INC CL  
     CMP CL, 4       ; telos an 4 psifia
     JNZ COUNT_READ2
  FORCE_ENTER:       ; Anagkastika perimene to enter meta apo 4 psifia
     CALL CHECKNUM
     CMP AL, 0DH
     JNZ FORCE_ENTER
                 
   DONE3:           ; deuteros ari8mos diavastike
     POP AX
     POP DX
     MOV DH,DL
	 MOV DL,0
     OR AX, DX
     CALL THE_TWO    
     MOV CL, AL
     POP AX
     POP DX
     MOV DH,DL
	 MOV DL,0
     OR AX, DX   
     CALL THE_TWO
     MOV CH, AL   ; O CX twra exei ton dekae3adiko deutero ari8mo
              
   ; prwta emfanisi se hex morfi          
     PRINT '='

     CMP DI,1         ; an - tote afairesi
     JZ  AFAIRESI
	 PRINT '+'
     ADD BX, CX          ; alliws prosthesi
     JMP NEXT0

 AFAIRESI:
		CMP BX,CX
		JNC DOSUB
		PRINT '-'
		MOV DI,2
        SUB BX,CX
        NEG BX
        JMP NEXT0
          
    DOSUB:SUB BX,CX       
 NEXT0:
	 MOV DX,0		; counter gia synexomena midenika
     MOV AL, BH          ; vazoume ta prwta 8 bit ston AL 
     CALL THE_ONE       ; i ONE mas vgazei tous ASCII ston AX
	 CMP AH,'0'
	 JNZ MOV1
	 INC DL
	 JMP MOV2
MOV1:PRINT AH		; diorthosi an yparxoun perita midenika stin arxi
MOV2:CMP AL,'0'
	 JNZ MOV3
	 CMP DL,1
	 JNZ MOV3
	 INC DL
	 JMP MOV4
MOV3:PRINT AL
MOV4:MOV AL, BL          ; vazoume ta deutera 8 bit ston AL
     CALL THE_ONE
   	 CMP AH,'0'
	 JNZ MOV5
	 CMP DL,2
	 JNZ MOV5
	 JMP MOV6
MOV5:PRINT AH		; diorthosi an yparxoun perita midenika stin arxi
MOV6:PRINT AL
MOV AL, BL          ; vazoume ta deutera 8 bit ston AL    
              
              
   ; emfanisi se BCD           
     PRINT '='      
     CMP DI,2
     JNZ NO_MINUS        ; Emfanisi prosimou kai sto BCD an arnitikos
     PRINT '-' 
 NO_MINUS:     
     CALL SHOW_BCD
      
                                        
     PRINT 0AH
     PRINT 0DH                                        
     JMP START                          

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                                                    

         
; THE_ONE: metatrepei 8-bit hex (AL) se 2 psifia asci (AH kai AL)
THE_ONE:    
          PUSH BX
          MOV BL, AL          ;apothikeuw ton arimthmo
          AND AL, 0F0H         ;krataw ta 4 MSB
		  
		  MOV AH,0
          PUSH DX
		  MOV BH,16
		  DIV BH
		  POP DX
		  
          CMP AL, 9H          ;elegxw me to 9
          JLE ISDEC       
          ADD AL, 37H         ;an einai gramma prosthetw 37H
          JMP OK
    ISDEC:ADD AL, 30H         ;an arithmos prosthetw 30H
    OK:   MOV AH, AL          ;apothikew sto AH
          MOV AL, BL
          AND AL, 0FH         ;antistoixa gia ta 4 LSB
          CMP AL, 9H
          JLE ISDEC2
          ADD AL, 37H
          JMP OK2
   ISDEC2:ADD AL, 30H              
          OK2:                     ;twra ston AX exoume kai ta 2 ASCII
          POP BX
          RET
    
; THE_TWO : metatrepei 2 psifia asci (AH kai AL) se 8-bit hex
THE_TWO:    
          CMP AL, 39H         ; prwta o xaraktiras ston AL
          JLE ARITHMOS
          CMP AL, 46H
          JLE MIKR
          SUB AL, 57H         ;an einai kefalaio afairei 57H
          JMP NEXT
                                    
  MIKR:   SUB AL, 37H         ;an einai mikro afairei 37H
          JMP NEXT

 ARITHMOS:SUB AL, 30H    ;an einai arithmos afairei 30H

  NEXT:   CMP AH, 39H    ; Ta idia gia ton AX
          JLE ARITHMOT
          CMP AH, 46H
          JLE MIKRO2
          SUB AL, 57H
          JMP TDONE

 MIKRO2:  SUB AH, 37H
          JMP TDONE

 ARITHMOT:SUB AH, 30H

  TDONE:  PUSH DX
		  PUSH BX
		  MOV BL,AL
		  MOV AL,AH
		  MOV AH,0
		  MOV DX,16
		  MUL DX
          OR AL, BL      ;ston AL exoume k ta 8bit
		  POP BX
		  POP DX
          RET


; Gia metatropi se BCD
DEGRADE:        ; number(ax) -> tens(dx), units(ax)
    CMP AX,10   ; an o sum > 10, diairesi me 10 afairontas
    JC thend
    INC DX
    SUB AX,10
    JMP DEGRADE
   thend:
    ret

;Emfanisi tou BX se bcd
SHOW_BCD:  
    MOV AX,BX
    MOV DX,0
    call DEGRADE  
    PUSH AX     ; units @ stack
    MOV AX,DX
    MOV DX,0 
    call DEGRADE
    PUSH AX      ; tens @ stack
    MOV AX,DX
    MOV DX,0
    call DEGRADE ; 
    PUSH AX     ; hundreds @ stack 
    MOV AX,DX
    MOV DX,0
    call DEGRADE ; 
    PUSH AX     ; thousands @ stack
    MOV AX,DX
    MOV DX,0
    call DEGRADE ; ten-thousands @ AL
    
	
	MOV BX,0	; Emfanisi apotelesmatos apo ti stoiva agnoontas midenika stin arxi
	CMP AL,0
	JNZ MOD1
	INC BL
	JMP MOD2
MOD1:ADD AL,'0'
    PRINT AL   ;show ten-thousands
MOD2:POP DX
	CMP DL,0
	JNZ MOD3
	CMP BL,1
	JNZ MOD3
	INC BL
	JMP MOD4
MOD3:ADD DL,'0'
    PRINT DL   ; show thousands
MOD4:POP DX
	CMP DL,0
	JNZ MOD5
	CMP BL,2
	JNZ MOD5
	INC BL
	JMP MOD6
MOD5:ADD DL,'0'
    PRINT DL   ;show hundreds
MOD6:POP DX
	CMP DL,0
	JNZ MOD7
	CMP BL,3
	JNZ MOD7
	JMP MOD8
MOD7:ADD DL,'0'
    PRINT DL   ;show tens
MOD8:POP DX
    ADD DL,'0'
    PRINT DL   ;show units
    RET        
                                                                                                                                        
;CHECKNUM: diavazei,  elegxei an diavase hex i pra3i kai ton typwnei
CHECKNUM: 
     MOV AH, 8
     INT 21H
     CMP AL, 'Q'
     JZ THE_END
     CMP AL, '-'
     JZ DONE0
     CMP AL, '+'
     JZ DONE0    
     CMP AL, 0DH    ;newline
     JZ DONE0
     CMP AL, 30H
     JL ERROR
     CMP AL, 30H
     JL ERROR
     CMP AL, 39H
     JLE DONE0
     CMP AL, 41H
     JL ERROR
     CMP AL, 46H
     JLE DONE0
     CMP AL, 61H
     JL ERROR
     CMP AL, 66H
     JLE DONE0
   ERROR:    JMP CHECKNUM
   DONE0:    RET               ;O ari8mos menei ston AL

		  
     THE_END:HLT
CODE ENDS
END
