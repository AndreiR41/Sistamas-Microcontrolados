;
; alocdin_mem.asm
;
; Created: 08/04/2025 15:25:06
; Author : andre
;
	.include "m328pdef.inc"

	.equ	numB 	= 20		; number of bytes in array
	.def	tmp	= r16		; define temp register
	.def	loopCt	= r17		; define loop count register
	.dseg
	.org	SRAM_START

sArr:	.BYTE	numB			; allocate bytes in SRAM for array

	.cseg
	.org	0x00

; carregar dados da memoria de programa só pode ser feito de forma indireta com ponteiros!!!
// vezes dois para fazer deslocamento a esquerda e consertar endereço
	//usado para acessar a localiza do array em sram, carrega com memoria dados
	ldi	XL,LOW(sArr)		; initialize X pointer
	ldi	XH,HIGH(sArr)		; to SRAM array address
	
	//usado para acessar o array na memoria de programa entao precisa converter de palavra p byte
	ldi	ZL,LOW(2*pArr)		; initialize Z pointer
	ldi	ZH,HIGH(2*pArr)		; to pmem array address
	

	ldi	loopCt,numB		; initialize loop count to number of bytes
//LPM: carrega a memoria do programa
arrLp:	lpm	tmp,Z+			;   carrega da memoria do programa tmp e incrementa Z
	st	X+,tmp			; store value to SRAM array
	dec	loopCt			; decrement loop count
	brne	arrLp			; repeat loop for all bytes in array

loop:	rjmp	loop			; infinite loop

; Espaço alocado tem que ser um número par!
//array da memoria de programa
pArr:	.db	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19		; program memory array //db é para carregar bits