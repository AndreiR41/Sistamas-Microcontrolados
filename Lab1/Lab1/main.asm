
;
	.include "m328pdef.inc"

	.equ	numB 	= 10		; number of bytes in array
	.dseg
	.org	SRAM_START

	;=================================================PILHA==================================================
sArr:	.BYTE	numB			; allocate bytes in SRAM for array

	.cseg
	.org	0x00

;=================================================SAÍDAS==================================================
organiza:
	; CONFIGURANDO PINOS DE SAÍDA
	LDI R23,(1<<PB0)
	OUT DDRB,R23     ; PB0 COMO SAÍDA
	LDI R23,(1<<PD2)|(1<<PD3)|(1<<PD4)|(1<<PD5)|(1<<PD6)|(1<<PD7)
	OUT DDRD,R23  ; PD7:PD2



; carregar dados da memoria de programa só pode ser feito de forma indireta com ponteiros!!!
;// vezes dois para fazer deslocamento a esquerda e consertar endereço

	;//usado para acessar o array na memoria de programa entao precisa converter de palavra p byte
	ldi	YL,LOW(2*pArr)		; inicia o ponteiro do array
	ldi	YH,HIGH(2*pArr)		; converte de palavra para byte
loop:
; carrea em XL para usar o mesmo binbcd do contador (adaptação do lab1 antigo)
	lpm XL,Y+           ; carrega e incrementa Y
	RCALL subcent
	RCALL exibir
	;comparar se chegou no ultimo valor (numbB==10) e se sim voltar pra o começo da pilha
	rjmp loop


	


; Espaço alocado tem que ser um número par!
;//array da memoria de programa
pArr:	.db	173,1,255,3,4,5,36,7,84,9		; program memory array //db é para carregar bits







;=================================================BIN-BCD==================================================

	;FAZER FUNCAO EXIBIR NOS DISPLAYS
	; ABSURDAMENTE ERRADO ESTAMOS PERDENDO A INFORMAÇÃO NO X (ATUAL PARA EXIBIR, ENTÃO FICAMOS CONTANDO DO 0 ATÉ O 1)
	;ARMAZENAR TEMPORIAMENTE O ATUAL PARA REALIZAR OPERAÇÕES E COMPARAÇÕES !!!!

	; 3 reg cent,dez,uni de 8 bits. Soma eles com respectivo valor 
	;Os 4 LSBs (r16[3:0]) sejam copiados para os pinos PD7, PD6, PD5, PD4 (em ordem).
	;Os 3 MSBs (r16[7:5]) sejam copiados para os pinos PB0, PD3, PD2 (em ordem).

subcent:
	; R16 <- XH , R17 <- XL
	MOV R16,XH
	MOV R17,XL
	CPI XH,0x00
	BREQ subcentlow
	SUBI R16,50
	SBCI R17,50
	INC R13

subcentlow:
	CPI  R17,0x64
	BRLO subdez
	SUBI R17,0x64
	INC R13
	CPI  R17,0x64
	BRGE subcent
	BRLO subdez

subdez:
	CPI R17,0x0A
	BRLO subuni
	SUBI R17,0x0A
	INC R14
	CPI R17,0x0A
	BRGE subdez
	BRLO subuni

subuni:
	CPI R17,0x00
	BREQ retorno

	SUBI R17,0x01
	INC R15
	CPI R17,0x01
	BRGE subuni
	RET	
retorno:                   ; Tive que seguir os passos da lenda...
	ret

;=================================================EXIBIÇÃO SAÍDAS==================================================
exibir:    ;R17 temporario    ===== R13 Centena, R14 Dezena , R13 Unidade

CENTENA:
	MOV R17,R13
	RCALL mirror
	SBI PORTB,0
	CBI PORTD,3
	CBI PORTD,2
	;RCALL delaymin
DEZENA:
	MOV R17,R14
	RCALL mirror
	CBI PORTB,0
	SBI PORTD,3
	CBI PORTD,2
	;RCALL delaymin
UNIDADE:
	MOV R17,R15
	RCALL mirror
	CBI PORTB,0
	CBI PORTD,3
	SBI PORTD,2
	;RCALL delaymin

	;vai contando 50 vezes para piscar
	INC R18
	CPI R18, 0x32
	BRLO exibir 

	RET

;=================================================SWAP e Espelhamento==================================================
mirror:
	
	SWAP R17; Trocamos as posições para poder mandar pros displays
	; troca os valores da posição dos bits
	; primeiro setamos tudo em zero
	LDI R19, 0x00 
	OUT PORTD,R19 ; Setamos todas as saídas com zero
	;fazemos a troca de posições e a saídas diretamente
	SBRC R17,7;esse comando pula a proxima linha se o bit indicado no registrador estiver limp
	SBI  PORTD, 4;nesse comando setamos o bit especifico na porta para exibição com base na checagem de R17
	; para portd5
	SBRC R17,6
	SBI  PORTD, 5
	; para portd6
	SBRC R17,5
	SBI  PORTD, 6
	; para portd7
	SBRC R17,4
	SBI  PORTD, 7
	RET

	

;=================================================DELAY==================================================	
delay:
	LDI R18,0x00
	LDI R19,0X00
	LDI R20,0x00

delayloop:
	DEC R18
	BRNE delayloop //enquanto R17>0 fica decrementando

	DEC R19
	BRNE delayloop

	DEC R20
	BRNE delayloop

	RET

delaymin:
	
	LDI R18,0x00
	LDI R19,0X00

delayminloop:
	DEC R18
	BRNE delayminloop

	DEC R19
	BRNE delayminloop

	RET
	
; 255*255*255 = 16581375 ~ 16 mega
; 255*255 = 65025
; decrementar 16 milhoes de vezes numa frequencia de 16 mega = 1 segundo