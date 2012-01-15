

PRINT MACRO CHAR	;tupwnei sthn o8onh to CHAR
     PUSH DX
     PUSH AX
	MOV DL,CHAR	;to CHAR einai timh se ASCII
	MOV AH,2	;epireazei DL kai AH
	INT 21H
     POP AX
     POP DX
ENDM




READ MACRO		;diavazei stdin kai ton epistrefei ston AL
	MOV AH,8  	;thn ASCII timh
	INT 21H		;Epireazei AL,AH
	MOV AH,0
ENDM

