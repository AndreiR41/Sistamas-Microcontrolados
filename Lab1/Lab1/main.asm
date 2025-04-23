;
; Lab1.asm
;
; Created: 31/03/2025 16:45:13
; Author : andre
;





.ORG 0x000    // enderco de inicio de escrita

;FALTA FAZER A FILA
; tudo funcionando aqui pra baixo
main:
	
	LDI R16,0xFF // carrega o valor 255
	;seta tudo em saida
	OUT DDRD,R16 //configura portB como saida
	LDI R17,R23 //numero que vai colocar
	RJMP subcent

exibir:
	MOV R17, R13
	;escreve o valor de r17 na port D
	OUT PORTD,R17
	RJMP atraso

	MOV R17, R14
	RJMP atraso

	MOV R17, R15
	RCALL atraso   //chama atraso
	RJMP main // pula de volta pra principal

	

subcent:
	SUBI R17,0x64
	INC R13
	CPI  R17,0x64
	BRGE subcent
	BRLO subdez

subdez:
	SUBI R17,0x0A
	INC R14
	CPI R17,0x0A
	BRGE subdez
	BRLO subuni

subuni:
;comparando se der ruim
	CPI R17,0x00
	BREQ organiza

	SUBI R17,0x01
	INC R15
	CPI R17,0x01
	BRGE subuni
	BRLO organiza

organiza:
	SWAP R13
	;ADIW R00,100
	SWAP R14
	;ADIW R01,010
	SWAP R15
	;ADIW R02,001
	RJMP exibir



;255x255x255
atraso:
	LDI R18,0x00
	LDI R19,0X00
	LDI R20,0x00

volta:
	DEC R18
	BRNE volta //enquanto R17>0 fica decrementando

	DEC R19
	BRNE volta

	DEC R20
	BRNE volta

	RET// retorna da sub-rotina








