
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h> // e lá vamos nós


#include "LCD.c"
#include "ADC.c"
#include "DAC.c"
#include "BOTAO.c"
#include "MODULACAO.c"


#define Analog0 PC0  // Pino A0

//==========================================FUNÇÕES==========================
void iniciar_IHM(void);
void IHM(void);
void ver_botao();
void MDE(int);

//==========================================VARIAVEIS==========================

volatile uint8_t btn_m_press = 0;
volatile uint8_t btn_up_press = 0;
volatile uint8_t btn_dw_press = 0;
//==========================================ENTRADA E SAÍDA====================
uint16_t x= 0;
uint8_t  y=0;

uint8_t m_atual = 0;
uint8_t passo = 1;

char Tipo_Mod[4]= "OFF";

//verificar aqui
uint8_t valorT = 249;
volatile int cont_lcd = 0;



//==========================================INIT==============================
//colocar dentro do init /setup
int main() {
    //Começa LCD e Botões
    iniciar_IHM();
    initADC();
    initDAC();
    timer1_ctc_init();

//===========================================TUDO ERRADO============================
    while (1) {
        /*
        if (cont_lcd == 500){
          IHM();
          cont_lcd = 0;
        }
*/
        ver_botao();
        //DAC
        fazerDAC(y);//fé que vira 8bits
			
	}
		
    
}



//============================================INIT===============================================I
void iniciar_IHM(){
    lcd_init();
    setup_botao();
    
}

//===========================================WHILE============================================I
void IHM(){
    // =================================EXIBICAO LCD=====================
        lcd_send_byte(0x80, 0);
        lcd_print("Mod:");  // Primeira linha
        lcd_send_byte(0x84, 0);
        lcd_print(Tipo_Mod);

        // Posiciona F ou T
        lcd_send_byte(0x88, 0);
        lcd_print("F*");

        // Formata e exibe o  Valor T ao lado de 
        char valorT_str[5];
        ident_num(valorT, valorT_str, 4);  //  dígitos para o valor
        lcd_print(valorT_str);

		// posiciona mensagem
		lcd_send_byte(0xC0, 0);
		lcd_print("Msg:");
		
}
// consegui fazer por interrupção
void ver_botao(){
    if (btn_m_press) {
        m_atual++;
        if (m_atual > 4) {
            m_atual = 0;
        }
        btn_m_press = 0;  // Reseta flag
    }
    if (btn_up_press) {
        valorT += passo;
        btn_up_press = 0;

    }
    if (btn_dw_press) {
        valorT -= passo;
        btn_dw_press = 0;
    }
    
}

// Rotina de Interrupção para PORTC
ISR(PCINT1_vect) {
    static uint8_t estado_passado = 0xFF;
    uint8_t estado_atual = PINC & ((1 << BTN_M) | (1 << BTN_UP) | (1 << BTN_DW));
    uint8_t pin_mudou = estado_atual ^ estado_passado;  // faz o ou exclusivo (XOR)
    
    // Detecta borda de descida (botão pressionado)
    if (pin_mudou) {
        _delay_us(50);  // Debounce rápido (50μs)
        estado_atual = PINC & ((1 << BTN_M) | (1 << BTN_UP) | (1 << BTN_DW));
        
        // Verifica quais botões foram pressionados
        if ((pin_mudou & (1 << BTN_M ))) btn_m_press  = !(estado_atual & (1 << BTN_M));
        if ((pin_mudou & (1 << BTN_UP))) btn_up_press = !(estado_atual & (1 << BTN_UP));
        if ((pin_mudou & (1 << BTN_DW))) btn_dw_press = !(estado_atual & (1 << BTN_DW));
        
        estado_passado = estado_atual;
    }
}

ISR(TIMER1_COMPA_vect) {
   x = readADC(Analog0);
	 x= x>>2;

   

  MDE(m_atual);
  cont_lcd++;
}

//adaptar mde para modificar T e F 
void MDE(int caso)
{
	switch (caso)
	{
		case 1:
            Tipo_Mod[0] = 'A';
            Tipo_Mod[1] = 'M';
            Tipo_Mod[2] = ' ';
            mostrar_int(x);
			      y=modulacao_am(x);
			break;
		case 2:
            Tipo_Mod[0] = 'F';
            Tipo_Mod[1] = 'M';
            Tipo_Mod[2] = ' ';
            mostrar_int(x);
			      y=modulacao_fm(x);
			break;
		case 3:
             Tipo_Mod[0] = 'A';
             Tipo_Mod[1] = 'S';
             Tipo_Mod[2] = 'K';
             mostrar_binario(x);
			      y=modulacao_ask(x);
			break;
		case 4:
            Tipo_Mod[0] = 'F';
            Tipo_Mod[1] = 'S';
            Tipo_Mod[2] = 'K';
            mostrar_binario(x);
			      y=modulacao_fsk(x);
			break;

        default:
            Tipo_Mod[0] = 'O';
            Tipo_Mod[1] = 'F';
            Tipo_Mod[2] = 'F';
            y=128;
	}
}


void mostrar_binario(uint8_t x) {
    // Posiciona cursor no LCD (exemplo: posição 0xC5)
    lcd_send_byte(0xC7, 0);
    char bin_str[8]={0};  // 8 bits + '\0'
    for (int i = 7; i >= 0; i--) {
        bin_str[7 - i] = (x & (1 << i)) ? '1' : '0';
    }
    bin_str[8] = '\0';  // Finaliza a string com terminador nulo
    // Imprime a string binária no LCD
    lcd_print(bin_str);
}

void mostrar_int(uint8_t x){
		lcd_send_byte(0xCC, 0);
		char mesagem_str[5];
        ident_num(x, mesagem_str, 4);  //  dígitos para o valor
        lcd_print(mesagem_str);
}  

void timer1_ctc_init() {
    TCCR1A = 0;                    // Modo CTC: só configura TCCR1B
    TCCR1B = (1 << WGM12)          // WGM12 = 1 → CTC
           | (1 << CS11) | (1 << CS10); // Prescaler 64

    OCR1A = 600;                   // 

    TIMSK1 |= (1 << OCIE1A);       // Habilita interrupção por comparação com OCR1A
    sei();                         // Habilita interrupções globais
}