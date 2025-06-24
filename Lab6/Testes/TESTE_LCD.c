#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#include "LCD.c"
#include "BOTAO.c"

// Array de 16 coeficientes 
static uint8_t coeficientes[16] = {
    123, 45, 67, 89, 
    101, 202, 3, 255, 
    99, 128, 77, 42,
    142, 231, 0, 199
};

int main() {
    lcd_init();
    lcd_print("Coeficiente");  // Primeira linha
    
    setup_botao();
    uint8_t m_atual= 0; // indice para percorrer o array
    uint8_t passo= 5; 

    while (1) {
      // se no pinoCx o bit especifico(mascara) for igual a zero significa que o pull up está ativo (true)
        uint8_t btn_m = (PINC & (1 << BTN_M)) == 0;
        uint8_t btn_up = (PINC & (1 << BTN_UP)) == 0;
        uint8_t btn_dw = (PINC & (1 << BTN_DW)) == 0;
    // =================================EXIBICAO LCD==============
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
        ident_num(coeficientes[m_atual], coef_str, 4);  // 3 dígitos para o valor
        lcd_print(coef_str);
        
        if (btn_m) {
              m_atual++;
              if (m_atual > 15) {
                  m_atual = 0;
              }
                  _delay_ms(300);  // Debounce para não contar várias vezes
          }
        if (btn_up){
          coeficientes[m_atual]=coeficientes[m_atual]+passo;
          _delay_ms(300); 
          }
        if (btn_dw){
          coeficientes[m_atual]=coeficientes[m_atual]-passo;
          _delay_ms(300); 	
          }        
  }
	_delay_ms(500);
}