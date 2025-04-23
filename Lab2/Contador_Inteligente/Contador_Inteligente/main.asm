;
; Contador_Inteligente.asm
;
; Created: 14/04/2025 16:47:13
; Author : andrei e marlucy
.org	0x00


.def Rpasso = R16



main:
	
	IN  DDRC,0x00 ;configura portC como entrada dos S1 S2 S3
	OUT DDRB, 0xFF; seta os pinos portB como saída para os led
	OUT DDRD, 0xFF; saidas display de 7 seg

	SBI   DDRC, 0 ; seta o pino C0 para ler o conversor

	;carregando os valores de Portc no registrador
	IN PINC,R17
	CPI PINC, 0x04
	BREQ setar_min


	 
	;decrementar s3 alto

	;incrementa s1 alto
	
setar_min:
	Sbi PORTB,1
	MOV XL,R18
	MOV XH,R19
	CPI PINC, 0x04
	BREQ setar_max

setar_max:
	Sbi PORTB,2
	MOV YL,R18
	MOV YH,R19
	CPI PINC, 0x04
	BREQ setar_passo

setar_passo:
	SBI PORTB,3
	MOV R16,R18
	CPI PINC, 0x04
	BREQ contagem
	
contagem:
	CPI PINC,0x02  ; 0b 0000 0010
	MOV ZL,XL
	MOV ZH,XH
	BREQ incrementar
	CPI PINC,0x08  ; 0b 0000 1000
	MOV ZL,YL
	MOV ZH,YH
	BREQ decrementar

;=================================================AC/DC==================================================


ativar_adc:
	;LDI R16,val_adc     ARRUMAR AQUI
	 LDI   R20, 0x40   ;	 ADC0
	 STS   ADMUX, R20
	
	 LDI   R20, 0x87   ; ADC, ADC prescalado CLK/128
     STS   ADCSRA, R20
comecar_adc:
	 LDI   R20, 0xC7   ;set ADSC in ADCSRA to start conversion
     STS   ADCSRA, R20

esperar_adc:
    LDS   R21, ADCSRA ;verifica ADIF flag interrupção no ADCSRA
    SBRS  R21, 4      ;nao pula quando completa
    RJMP  esperar_adc  ;no loop ate setar adif
    ;--------------------------------------------------------------
    LDI   R17, 0xD7   ;seta adif dnv
    STS   ADCSRA, R17 ;
    ;--------------------------------------------------------------
    LDS   R18, ADCL   ;
    LDS   R19, ADCH   ;
    RETI

;=================================================inc/dec==================================================

incrementar:
	;exibir
	ADD ZL,Rpasso
	ADC ZH,ZL
	SUB ZH,ZL
	CPI PINC,0x00
	BREQ incrementar
	CPI PINC,0x08
	BREQ decrementar
	;CPI Rmin, Ratual
	;BRLO incrementar

decrementar:
	;exibir
	SUB ZL,Rpasso
	SBC ZH,ZL
	ADD ZH, ZL
	CPI PINC,0x00
	BREQ decrementar
	CPI PINC,0x02
	BREQ incrementar
	;CPI Rmax,Ratual
	;BRSH decrementar


;=================================================exibir==================================================


exibir:
	;exibir o valor atual
	;carregar na portd
	MOV R12, R13
	;escreve o valor de r12 na port D
	OUT PORTD,R12
	RJMP atraso
	MOV R12, R14
	RJMP atraso
	MOV R12, R11
	RCALL atraso   //chama atraso
	RJMP main // pula de volta pra principal

subcent:
	SUBI R12,0x64
	INC R13
	CPI  R12,0x64
	BRGE subcent
	BRLO subdez

subdez:
	SUBI R12,0x0A
	INC R14
	CPI R12,0x0A
	BRGE subdez
	BRLO subuni

subuni:
	;comparando se der ruim
	CPI R12,0x00
	BREQ organiza
	SUBI R12,0x01
	INC R11
	CPI R12,0x01
	BRGE subuni
	BRLO organiza

organiza:
	SWAP R13
	;ADIW R00,100
	SWAP R14
	;ADIW R01,010
	SWAP R11
	;ADIW R02,001
	RJMP exibir