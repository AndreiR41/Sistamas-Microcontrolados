
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#include "EEPROM.c"
#include "LCD.c"

#include "ADC.c"
#include "DAC.c"
#include "BOTAO.c"


#define Analog0 PC0  // Pino A0

//==========================================FUNÇÕES==========================
void iniciar_IHM(void);
void array_adc(void);
void IHM(void);

//==========================================VARIAVEIS==========================
uint8_t coef_inicial[16] ={1, 1,  3,  5,  7,  9, 11, 12, 12, 11,  9,  7,  5,  3,  1,  1};// inicializando com os coef calculados
// Fs = pequena-> Fnyquist = Fs/2
uint8_t c[16]; // coeficientes Para filtragem
uint8_t m_atual = 0;
uint8_t passo = 1;

int16_t x[16] = {0}; 
uint8_t indice = 0;

int32_t y = 0;

uint8_t tempo= 0; 
//==========================================INIT==============================

//colocar dentro do init /setup
int main() {

   EEPROM_escrever_array(coef_inicial);
    // multiplicar coeficientes de h *100float->int
    // CARREGA EEPROM DOS COEFICIENTES
    EEPROM_ler_array(c);
    //Começa LCD e Botões
    iniciar_IHM();
    initADC();
    initDAC();

	
//===========================================TUDO ERRADO============================
    while (1) {
        // pega amostras de x array circular
        // x[i]<- adc
        int16_t x_adc = readADC(Analog0);
	      x_adc= x_adc>>2;
        x[indice] = x_adc;
        
        //exibe e verifica os botoes
       IHM();

      //convolução/ filtragem 
		// y[n] = sum_{i=0}^{N-1}  c[i] * x[n - i]
		// y[n] = c[0]*x[n] + c[1]*x[n-1] + c[2]*x[n-2] + ... + c[N-1]*x[n-(N-1)]
		int32_t y = 0;
		
		for (uint8_t i = 0; i < 16; i++) {
		    uint8_t idx = (indice + 16 - i) % 16;  // acesso circular
		    y += c[i] * x[idx];
		}
    
    y=y/100;                                           //FALTA TESTAR COM RUÍDO
  //testando fs
    if(tempo==0){
      tempo= 255;
    }else{
      tempo=0;
    }
        //DAC
    fazerDAC(y);//fé que vira 8bits
		
		//aumenta o indice <16
		indice = (indice + 1) % 16;
		
    }
  //sem delay
}



//============================================INIT===============================================I
void iniciar_IHM(){
    lcd_init();
    lcd_print("Coeficiente");  // Primeira linha
    setup_botao();
    
}


//===========================================WHILE============================================I
void IHM(){
    // se no pinoCx o bit especifico(mascara) for igual a zero significa que o pull up está ativo (true)
        uint8_t btn_m =  (PINC & (1 << BTN_M)) == 0;
        uint8_t btn_up = (PINC & (1 << BTN_UP)) == 0;
        uint8_t btn_dw = (PINC & (1 << BTN_DW)) == 0;
    // =================================EXIBICAO LCD=====================
        // Posiciona no início da segunda linha (0xC0)
        lcd_send_byte(0xC0, 0);
        
        // Formata e exibe o índice atual
        char indice_str[4];
        ident_num(m_atual, indice_str, 3);  // 2 dígitos para o índice
        lcd_print("C");
        lcd_print(indice_str);
        lcd_print(":");
        
        // Formata e exibe o coeficiente atual
        char coef_str[5];
        ident_num(c[m_atual], coef_str, 4);  // 3 dígitos para o valor
        lcd_print(coef_str);
        
        if (btn_m) {
              m_atual++;
              if (m_atual > 15) {
				         EEPROM_escrever_array(c);
                  m_atual = 0;
              }
                  _delay_ms(300);  // Debounce para não contar várias vezes
          }
        if (btn_up){
          c[m_atual]=c[m_atual]+passo;
          _delay_ms(300); 
          }
        if (btn_dw){
          c[m_atual]=c[m_atual]-passo;
          _delay_ms(300); 	
          }  
}






