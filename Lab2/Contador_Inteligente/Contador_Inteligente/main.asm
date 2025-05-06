;
; Contador_Inteligente.asm
;
; Created: 14/04/2025 16:47:13
; Author : andrei e marlucy
.include "m328pdef.inc"

.org	0x0000
; DEBUG 
	RJMP botoes

.org 0x0008        ; Vetor da interrupção PCINT1 (PORTC) mudança de valor
    rjmp PCINT_ISR




;=================================================AC/DC==================================================

ativar_adc:
	
	 LDI   R20, 0x40   ;	 ADC0   0100 0000 para escolher A0
	 STS   ADMUX, R20
	
	 LDI   R20, 0x87   ; ADC, ADC prescalado CLK/128 -1000 0111
     STS   ADCSRA, R20
comecar_adc:
	 LDI   R20, 0xC7   ; 1100 0111
     STS   ADCSRA, R20

esperar_adc:
    LDS   R21, ADCSRA ;verifica ADIF flag interrupção no ADCSRA
    SBRS  R21, 4      ;só pula quando completa, ou seja adif ativa
    RJMP  esperar_adc  ;no loop ate setar adif
    ;--------------------------------------------------------------
    LDI   R17, 0xD7   ;seta adif dnv
    STS   ADCSRA, R17 ;
    ;--------------------------------------------------------------
    LDS   R18, ADCL   ;
    LDS   R19, ADCH   ;
    RET

;=================================================BOTÕES==================================================
; Configura PC1, PC2, PC3 como entrada
botoes:
    LDI R16, 0b00000000
    OUT DDRC, R16
	LDI R16, 0b00001110     ; Ativa pull-up interno nos pinos PC1, PC2, PC3
	OUT PORTC, r16
/*
leds:
	sbi DDRB, PB1
	sbi DDRB, PB2
	sbi DDRB, PB3*/
	

;=================================================HABILITA INTERRUPÇÃO==================================================
; Habilita interrupções PCINT9 (PC1) e PCINT11 (PC3)                          SIMULADOR NÃO FAZ INTERRUPÇÃO
    LDI r16, (1<<PCINT9) | (1<<PCINT11)
    STS PCMSK1, r16      ; Habilita bits individuais
    LDI r16, (1<<PCIE1)
    STS PCICR, r16        ; Habilita grupo PCINT1 (PORTC)
	SEI
	
;=================================================SAÍDAS==================================================
organiza:
	; CONFIGURANDO PINOS DE SAÍDA
	LDI R23,(1<<PB0)
	OUT DDRB,R23     ; PB0 COMO SAÍDA
	LDI R23,(1<<PD2)|(1<<PD3)|(1<<PD4)|(1<<PD5)|(1<<PD6)|(1<<PD7)
	OUT DDRD,R23  ; PD7:PD2


;=================================================INICIAL==================================================
inicial: 
	; Carregando os valores de ATUAL
	LDI XL, 0x00
	LDI XH, 0x00
	; Carregando os valores de MAXIMO
	LDI YL, 0xE7
	LDI YH, 0x03
	; Carregando os valores de MINIMO
	LDI ZL, 0x00
	LDI ZH, 0x00
	; Carregando o valor de PASSO
	LDI R25,0x01
	; carregando registrador com zero para somar 16 bits com 8 GAMBIARRA
	LDI R24, 0x00 

	 
;=================================================CONTAGEM PADRÃO==================================================


contagem:
; FAZER Comparações S1,S2,S3											 por causa do PULL-UP interno se On =0 se Off =1
	IN R17, PINC            ; Lê estado dos pinos de entrada (PORTC)
	; Se PC2 == 1, pula a próxima instrução
	; Se PC2 == 0 ? botão pressionado
; Verifica se botão em PC2 está pressionado
	SBRC R17,PC2
	RCALL minimo
	


;CONTAGEM PADRÃO
	LDI R17,0x00 ; LIMPA O TEMP PARA USAR NO SWAP
	MOV R13,R24
	MOV R14,R24 ; LIMPANDO OS CONTADORES BCD ANTES DE REALIZAR A PROXIMA EXIBIÇÃO
	MOV R15,R24 

	ADD XL, R25
	ADC XH, R24
	RCALL subcent    ; faz o BIN-BCD
	RCALL exibir     ; mostra nos displays

	RCALL delay

	; compara com o maximo
	CP XL,YL
	CPC XH,YH
	BRLO contagem; se menor volta para contagem
	BRSH inicial ; se maior ou igual voltar para o inicio

;=================================================INCREMENTAR==================================================
; carrega os valores de minimo no atual

incrementar:	
	ADD XL, R25
	ADC XH, R24

	CP XL,YL
	CPC XH,YH
	RCALL subcent
    RCALL exibir
    RCALL delay

	BRLO incrementar; se menor volta para inc
	RET ; se maior ou igual voltar 

;=================================================DECREMENTAR==================================================
decrementar:
	; subtrai atual com o passo
	SUB XL, R25
	SBC XH, R24

	CP XL,ZL
	CPC XH,ZH
	RCALL subcent
	RCALL exibir
	RCALL delay

	BRSH decrementar ; se maior ou igual voltar para o DEC
	RET ; se menor voltar 

;=================================================S2==================================================

;INSERIR MINIMO, INSERIR MAXIMO, INSERIR PASSO 
	
	minimo:
;		CHAMAR ADC E CARREGAR EM Z O VALOR LIDO
		RCALL ativar_adc
		
		MOV ZL,R18 ; O valor menos significativo de ADC
		MOV ZH,R19 ; O valor menos significativo de ADC
		RCALL exibir
		;chama delay para esperar um segundo antes de ler os pinos C
		RCALL delay
		
		IN R17, PINC 
		; Verifica se botão em PC2 está pressionado
		SBRC R17,PC2
		RCALL Maximo
		RJMP minimo
		

	Maximo:
		;CHAMAR ADC E CARREGAR EM Y O VALOR LIDO
		RCALL ativar_adc

		MOV YL,R18 ; O valor menos significativo de ADC
		MOV YH,R19 ; O valor menos significativo de ADC
		RCALL exibir
		;chama delay para esperar um segundo antes de ler os pinos C
		RCALL delay

		IN R17, PINC 
		SBRC R17,PC2
		RCALL passo
		RJMP Maximo
		

	passo:
		;CHAMAR ADC E CARREGAR EM R25 O VALOR LIDO
		RCALL ativar_adc

		MOV R25,R18 ; O valor menos significativo de ADC
		RCALL exibir
		;chama delay para esperar um segundo antes de ler os pinos C
		RCALL delay

		IN R17, PINC 
		SBRC R17,PC2
		RJMP contagem
		RJMP passo
		
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
		;CENTENA
		MOV R17,R13
		RCALL mirror
		MOV R13,R17
		LDI R23,0b000000000
		ADD R13,R23
		OUT PORTD, R13
		SBI PORTB,0
		RCALL delaymin
		; DEZENA
		MOV R17,R14
		RCALL mirror
		LDI R23,0b000001000
		MOV R14,R17
		ADD R14,R23
		OUT PORTD, R14
		CBI PORTB,0
		RCALL delaymin
		; UNIDADE
		MOV R17,R15
		RCALL mirror
		LDI R23,0b000000100
		MOV R15,R17
		ADD R15,R23
		OUT PORTD, R15
		CBI PORTB,0
	
		;vai contando 50 vezes para piscar
		INC R25
		CPI R25,50
		BRLO exibir 

	RET

;=================================================SWAP==================================================
mirror:
	;MOV R17, R13  ; EXIBINDO CENTENA 
	SWAP R17
	; COMPARA COM ZERO ATÉ NOVE

	CPI R17, 0x00
	BREQ N0

	CPI R17, 0x10
	BREQ N1

	CPI R17, 0x20
	BREQ N2

	CPI R17, 0x30
	BREQ N3

	CPI R17, 0x40
	BREQ N4

	CPI R17, 0x50
	BREQ N5

	CPI R17, 0x60
	BREQ N6

	CPI R17, 0x70
	BREQ N7

	CPI R17, 0x80
	BREQ N8

	CPI R17, 0x90
	BREQ N9

	
	

;=================================================ESPELHAMENTO==================================================
N0:
	LDI R17, 0x00
	RET
N1:
	LDI R17, 0x80
	RET
N2:
	LDI R17, 0x40
	RET
N3:
	LDI R17, 0xC0  ;doze
	RET
N4:
	LDI R17, 0x20
	RET
N5:
	LDI R17, 0xA0
	RET
N6:
	LDI R17, 0x60
	RET
N7:
	LDI R17, 0xE0
	RET
N8:
	LDI R17, 0x10
	RET
N9:
	LDI R17, 0x90
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
; decrementar 16 milhoes de vezes numa frequencia de 16 mega = 1 segundo


;=================================================ROTINA DE INTERRUPÇÃO==================================================
; ENTENDER O SENTIMENTO DA COISA
PCINT_ISR:
	RCALL delay
    IN R17, PINC          ; Lê o estado atual do PINC

    ; Checa se PC1 (PCINT9) está em nível baixo (botão pressionado)
    SBRC R17, PC1
    RCALL incrementar

    ; Checa se PC3 (PCINT11) está em nível baixo (botão pressionado)
    SBRC R17, PC3
    RCALL decrementar

    RETI