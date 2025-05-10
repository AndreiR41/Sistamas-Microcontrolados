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
; setando os leds como saída
leds:
	sbi DDRB, PB1
	sbi DDRB, PB2
	sbi DDRB, PB3
	

;=================================================HABILITA INTERRUPÇÃO==================================================
; Habilita interrupções PCINT9 (PC1) e PCINT11 (PC3)                          SIMULADOR NÃO FAZ INTERRUPÇÃO
    LDI r16, (1<<PCINT9) | (1<<PCINT10) | (1<<PCINT11)
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

	CLR R21 ; 

	 
;=================================================CONTAGEM PADRÃO==================================================


contagem:
	
	; FAZER Comparações S1,S2,S3											 por causa do PULL-UP interno se On =0 se Off =1
	CPI R21,1
	BREQ incrementar
	CPI R21,2
	BREQ decrementar
	CPI R21,3
	BREQ minimo
	; Se PC2 == 1, pula a próxima instrução
	; Se PC2 == 0 ? botão pressionado
	; Verifica se botão em PC2 está pressionado
	
	CLR R13
	CLR R14
	CLR R15
	CLR R16
	CLR R17
	CLR R18
	CBI PORTB,PB1
	CBI PORTB,PB2 
	CBI PORTB,PB3    ; DESLIGANDO O LED

	;CONTAGEM PADRÃO
	;LDI R17,0x00 ; LIMPA O TEMP PARA USAR NO SWAP

	ADD XL, R25
	ADC XH, R24
	MOV R16,XH
	MOV R17,XL
	RCALL subcent    ; faz o BIN-BCD
	CLR R22
	RCALL exibir     ; mostra nos displays


	; compara com o maximo
	CP XL,YL
	CPC XH,YH
	BRLO contagem; se menor volta para contagem
	BRSH inicial ; se maior ou igual voltar para o inicio


;=================================================INCREMENTAR==================================================
; carrega os valores de minimo no atual

incrementar:	
	CLR R13   ; limpa a memoria do bin bcd
	CLR R14
	CLR R15
	CLR R21
	LDI R25, 5
	;
	ADD XL, R25
	ADC XH, R24

	CP XL,YL
	CPC XH,YH 
	BRSH contagem   ; Se maior carrega retorna pra contagem
	MOV R16,XH
	MOV R17,XL
	RCALL subcent
    RCALL exibir
	
	RJMP incrementar


;=================================================DECREMENTAR==================================================
decrementar:
	CLR R13   ; limpa a memoria do bin bcd
	CLR R14
	CLR R15
	CLR R21
	; subtrai atual com o passo
	LDI ZL,0x02
	CLR ZH ; valor minimo 2
	LDI R25,2
	;
	SUB XL, R25
	SBC XH, R24

	CP XL,ZL
	CPC XH,ZH
	BRLO inicial ;se menor  volta pra contagem padrão
	MOV R16,XH
	MOV R17,XL
	RCALL subcent
	RCALL exibir
	
	
	RJMP decrementar ; se maior ou igual voltar para o DEC
	

;=================================================S2==================================================

;INSERIR MINIMO, INSERIR MAXIMO, INSERIR PASSO 
	
	minimo:
		CBI PORTB,PB1    ; LIGANDO O LED
		CBI PORTB,PB2 
		SBI PORTB,PB3
;		CHAMAR ADC E CARREGAR EM Z O VALOR LIDO
		RCALL ativar_adc
		
		MOV ZL,R18 ; O valor menos significativo de ADC
		MOV ZH,R19 ; O valor menos significativo de ADC
		ROR ZH
		ROR ZL ;1
		CLC
		ROR ZH ;2
		ROR ZL
		CLC
		ROR ZH ;3
		ROR ZL
		CLC
		ROR ZH ;4
		ROR ZL
		CLC
		ROR ZH ;5
		ROR ZL
		CLC
		ROR ZH ;6
		ROR ZL
		CLC
		;CONFIGURANDO SÓ PARA O BIN BCD
		MOV R16,ZH
		MOV R17,ZL
		RCALL subcent
		RCALL exibir

		
	
		; Verifica se botão em PC2 está pressionado
		SBIS  PINC,PC2
		RCALL Maximo
		RJMP  minimo

		

	Maximo:
		CBI PORTB,PB1
		SBI PORTB,PB2    ; LIGANDO O LED
		CBI PORTB,PB3 
		
		;CHAMAR ADC E CARREGAR EM Y O VALOR LIDO
		RCALL ativar_adc

		MOV YL,R18 ; O valor menos significativo de ADC
		MOV YH,R19 ; O valor menos significativo de ADC
		ROR ZH
		ROR ZL ;1
		CLC
		ROR ZH ;2
		ROR ZL
		CLC
		ROR ZH ;3
		ROR ZL
		CLC
		ROR ZH ;4
		ROR ZL
		CLC
		ROR ZH ;5
		ROR ZL
		CLC
		ROR ZH ;6
		ROR ZL
		CLC
		;CONFIGURANDO SÓ PARA O BIN BCD
		MOV R16,YH
		MOV R17,YL
		RCALL subcent
		RCALL exibir


		SBIS PINC,PC2
		RCALL passo
		RJMP Maximo
		

	passo:
		SBI PORTB,PB1
		CBI PORTB,PB2 
		CBI PORTB,PB3    ; LIGANDO O LED

		;CHAMAR ADC E CARREGAR EM R25 O VALOR LIDO
		RCALL ativar_adc
		;FAZER UM AND  COM 0XF0 5V/16BITS PARA DIMINUIR RESOLUÇÃO E CONTAR ATÉ PROXIMO DE 15
		ANDI R19, 0XF0
		MOV R25,R19 ; O valor mais significativo de ADC
		RCALL subcent
		RCALL exibir
		
		
		RETI
		
		
		

;=================================================BIN-BCD==================================================
	;3 reg cent,dez,uni de 8 bits. Soma eles com respectivo valor 
	;Os 4 LSBs (r16[3:0]) sejam copiados para os pinos PD7, PD6, PD5, PD4 (em ordem).
	;Os 3 MSBs (r16[7:5]) sejam copiados para os pinos PB0, PD3, PD2 (em ordem).

subcent:
	; R16 <- XH , R17 <- XL
	CPI XH,0x00
	BREQ subcentlow ;
	SUBI R16,50
	SBCI R17,50
	INC R13
	;TERMINAR 
	CPI R16, 0x00
	BREQ subcentlow
	RJMP subcent

subcentlow:
	CPI  R17,0x64
	BRLO subdez
	SUBI R17,0x64
	INC R13
	CPI  R17,0x64
	BRGE subcentlow
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
	

retorno:                   ; Tive que seguir os passos da lenda...
	RET

;=================================================EXIBIÇÃO SAÍDAS==================================================
exibir:    ;R17 temporario    ===== R13 Centena, R14 Dezena , R15 Unidade
	
CENTENA:
	MOV R17,R13
	RCALL mirror
	SBI PORTB,0
	CBI PORTD,3
	CBI PORTD,2
	RCALL delaymin
DEZENA:
	MOV R17,R14
	RCALL mirror
	CBI PORTB,0
	SBI PORTD,3
	CBI PORTD,2
	RCALL delaymin
UNIDADE:
	MOV R17,R15
	RCALL mirror
	CBI PORTB,0
	CBI PORTD,3
	SBI PORTD,2
	RCALL delaymin

	;vai contando 50 vezes para piscar
	INC R22
	CPI R22, 50
	BREQ retorno
	RJMP exibir	

;=================================================SWAP e Espelhamento==================================================
mirror:
	
	SWAP R17; Trocamos as posições para poder mandar pros displays
	; troca os valores da posição dos bits
	CLR R24
	OUT PORTD,R24 ; Setamos todas as saídas com zero
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
	CLR R10
	CLR R11
	CLR R12

delayloop:
	DEC R10
	BRNE delayloop //enquanto R17>0 fica decrementando

	DEC R11
	BRNE delayloop

	DEC R12
	BRNE delayloop

	RET

delaymin:
	
	CLR R10
	CLR R11

delayminloop:
	DEC R10
	BRNE delayminloop

	DEC R11
	BRNE delayminloop

	RET
	
; 255*255*255 = 16581375 ~ 16 mega
; 255*255 = 65025
; decrementar 16 milhoes de vezes numa frequencia de 16 mega = 1 segundo


;=================================================ROTINA DE INTERRUPÇÃO==================================================
; ENTENDER O SENTIMENTO DA COISA
PCINT_ISR:
	CLR R21
    ; Checa se PC1 (PCINT9) está em nível baixo (botão pressionado)
    SBIS PINC, PC1   ; CHECA AS PORTAS DE IO
    LDI  R21, 1

	 ; Checa se PC2 (PCINT10) está em nível baixo (botão pressionado)
    SBIS PINC, PC2
	LDI R21,3
   

    ; Checa se PC3 (PCINT11) está em nível baixo (botão pressionado)
    SBIS PINC, PC3
	LDI  R21, 2
   

    RETI