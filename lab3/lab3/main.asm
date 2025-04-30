;
; lab3.asm
;
; Created: 28/04/2025 16:50:01
; Author : andre
;

.org	0x0000
; DEBUG 
	RJMP botoes

.org 0x0008        ; Vetor da interrupção PCINT1 (PORTC) mudança de valor
    rjmp PCINT_ISR
 ;=================================================PWM==================================================

delay10us:                    ; Sub-rotina para delay de ~10 microssegundos
;-----------------------------------------------
    CLR   R20                 ; Zera o registrador R20
    OUT   TCNT0, R20          ; Reinicia o contador do Timer0 (TCNT0 = 0)
    
    LDI   R20, 20             ; Carrega valor de comparação para 10 µs (ajustável conforme o clock)
    OUT   OCR0A, R20          ; Define o valor a ser comparado (Output Compare Register A)

    LDI   R20, 0b00001010     ; Configura Timer0: modo CTC (Clear Timer on Compare Match), prescaler = 8
                              ; TCCR0B = (1 << WGM02) | (1 << CS01)
    OUT   TCCR0B, R20         ; Ativa o Timer0 com essas configurações
;-----------------------------------------------    
espera_compare:
    IN    R20, TIFR0          ; Lê o registrador de flags de interrupção (TIFR0)
    SBRS  R20, OCF0A          ; Verifica se a flag de comparação OCF0A está setada
    RJMP  espera_compare      ; Se ainda não ocorreu, continua esperando
;-----------------------------------------------
    CLR   R20                 
    OUT   TCCR0B, R20         ; Para o Timer0 (zera o registrador de controle)

    LDI   R20, (1 << OCF0A)   ; Prepara para limpar a flag OCF0A (bit 1 do TIFR0)
    OUT   TIFR0, R20          ; Limpa a flag de comparação (OCF0A) manualmente
;-----------------------------------------------
    RET                       ; Retorna da sub-rotina


; ;=================================================BOTÕES==================================================
; Configura PC1, PC2, PC3 como entrada
botoes:
    LDI R16, 0b00000000
    OUT DDRC, R16
	LDI R16, 0b00001110     ; Ativa pull-up interno nos pinos PC1, PC2, PC3
	OUT PORTC, r16
	
;=================================================HABILITA INTERRUPÇÃO==================================================
; Habilita interrupções PCINT9 (PC1)                         SIMULADOR NÃO FAZ INTERRUPÇÃO
    LDI r16, (1<<PCINT9) 
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

;=================================================ESPERAR================================================
;Homenagem ao grande JV
esperar:
	LDI XL,0x00
	LDI XH,0x00
	;RJMP esperar
;=================================================SENSOR==================================================
HC_SR04_sensor:

    SBI   DDRC, 4         ;Trigger - SDA
    CBI   DDRC, 5		  ; Echo   - SCL
	

;=================================================MEDIR==================================================
medir:
	; distancia <---converte---- sensor
	;X<- distancia
	;exibir X
	/*
	MOV R16,XH
	MOV R17,XL
	RCALL exibir
	*/


	; Garante que começa com TRIG em 0
	CBI PORTC, 4         
	RCALL Delay10us  


	RCALL delay
	IN R16, PINC

	SBRS R16,PC2
	RJMP salvar
	RJMP medir


	

;=================================================SALVAR=================================================
salvar:
	;Y<-X
	;eeprom <- Y
	RCALL eeprom_escrever
	;exibir X
	/*
	MOV R16,XH
	MOV R17,XL
	RCALL exibir
	*/
	;verificar se S3 foi pressionado:
	RCALL delay
	IN R16, PINC
	SBRS R16,PC3
	RJMP lembrar
	RJMP salvar

;=================================================LEMBRAR================================================
lembrar:
	
	;exibir Y
	RCALL eeprom_escrever
	/*
	MOV R16,YH
	MOV R17,YL
	RCALL exibir
	*/
	RJMP lembrar


	
;=================================================EEPROM==================================================
EEPROM_escrever:
	
	; endereço R17:18 no registrador
	out EEARH, r18
	out EEARL, r17
	; escreve os dados  de R16
	out EEDR,r16 ; configura registrador de eeprom carregnado com temp R16
	;EEMPE em 1 para poder escrever na eeprom depois de 4 ciclos de clock
	sbi EECR,EEMPE
	; Seta EEPE 
	sbi EECR,EEPE

	; espera completar leitura
	sbic EECR,EEPE
	rjmp EEPROM_escrever
	ret

EEPROM_ler:
	; Wait for completion of previous write
	sbic EECR,EEPE
	rjmp EEPROM_ler
	; Set up address (r18:r17) in address register
	out EEARH, r18
	out EEARL, r17
	; Start eeprom read by writing EERE
	sbi EECR,EERE
	; Read data from Data Register
	in r16,EEDR
	ret










;=================================================BIN-BCD==================================================

	;FAZER FUNCAO EXIBIR NOS DISPLAYS
	; ABSURDAMENTE ERRADO ESTAMOS PERDENDO A INFORMAÇÃO NO X (ATUAL PARA EXIBIR, ENTÃO FICAMOS CONTANDO DO 0 ATÉ O 1)
	;ARMAZENAR TEMPORIAMENTE O ATUAL PARA REALIZAR OPERAÇÕES E COMPARAÇÕES !!!!

	; 3 reg cent,dez,uni de 8 bits. Soma eles com respectivo valor 
	;Os 4 LSBs (r16[3:0]) sejam copiados para os pinos PD7, PD6, PD5, PD4 (em ordem).
	;Os 3 MSBs (r16[7:5]) sejam copiados para os pinos PB0, PD3, PD2 (em ordem).

subcent:
	; R16 <- XH , R17 <- XL
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
	; DEZENA
	MOV R17,R14
	RCALL mirror
	LDI R23,0b000001000
	MOV R14,R17
	ADD R14,R23
	OUT PORTD, R14
	CBI PORTB,0
	; UNIDADE
	MOV R17,R15
	RCALL mirror
	LDI R23,0b000000100
	MOV R15,R17
	ADD R15,R23
	OUT PORTD, R15
	CBI PORTB,0
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

	;OUT PORTD,R17
	

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
; 255*255*255 = 16581375 ~ 16 mega
; decrementar 16 milhoes de vezes numa frequencia de 16 mega = 1 segundo


;=================================================ROTINA DE INTERRUPÇÃO==================================================
; ENTENDER O SENTIMENTO DA COISA
PCINT_ISR:
	;RCALL delay
    IN R17, PINC          ; Lê o estado atual do PINC

    ; Checa se PC1 (PCINT9) está em nível baixo (botão pressionado)
    SBRS R17, PC1
    RCALL medir


    RETI