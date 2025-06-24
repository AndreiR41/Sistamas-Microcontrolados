#define F_CPU 16000000UL
#include <util/delay.h>
#include <avr/interrupt.h>

#include "LED_PWM.c"
#include "LCD.c"

volatile uint8_t t_on = 0, timer = 0, passo = 5;

int main() {
    setup_pwm();
    uint8_t m_atual= 0;
    uint8_t red = 0, green = 0, blue = 0;
    lcd_init();
    lcd_print("RED  GREEN  BLUE");
    lcd_send_byte(0xC0, 0); // Pula para a segunda linha // pagina 164 AVR

    //timer 0
    TCCR0A = 0b00000001 ; 
    TCCR0B = 0b00000101 ;
    TIMSK0 = 0b00000001;
    OCR0A = 254;
    sei();
    
    while (1) {
        // se no pinoCx o bit especifico(mascara) for igual a zero significa que o pull up está ativo (true)
        uint8_t btn_m = (PINC & (1 << BTN_M)) == 0;
        uint8_t btn_up = (PINC & (1 << BTN_UP)) == 0;
        uint8_t btn_dw = (PINC & (1 << BTN_DW)) == 0;

    //====================================================DISPLAY-LCD===========================================
        // Segunda linha - Valores RGB
          // Posicao C0 (Coluna 1)
          lcd_send_byte(0xC0, 0);
          char red_str[4];
          ident_num(red, red_str, 4);
          lcd_print(red_str);

          // Posi��o C6 (Coluna 7)
          lcd_send_byte(0xC6, 0);
          char green_str[4];
          ident_num(green, green_str, 4);
          lcd_print(green_str);

          // Posi��o CC (Coluna 13)
          lcd_send_byte(0xCC, 0);
          char blue_str[4];
          ident_num(blue, blue_str, 4);
          lcd_print(blue_str);

          _delay_ms(500);
        
//====================================================LED-RGB-PWM===========================================
        if (btn_m) {
            m_atual++;
            if (m_atual > 3) {
                m_atual = 0;
            }
    _delay_ms(300);  // Debounce para não contar várias vezes
}
         
       switch (m_atual) {
            case 0:
                lcd_send_byte(0xC4, 0); // Coluna 3 (após Red)
                lcd_print(" ");
                lcd_send_byte(0xC9, 0); // Coluna 9 (após Green)
                lcd_print(" ");
                lcd_send_byte(0xCF, 0); // Coluna 15 (após Blue)
                lcd_print(" ");
                break;
            case 1:
                if (btn_up) red=red+passo;
                if (btn_dw) red=red-passo;
                t_on = 1;
                //pos LCD C4 com *
                lcd_send_byte(0xC4, 0); // Coluna 3 (após Red)
                lcd_print("*");
                lcd_send_byte(0xC9, 0); 
                lcd_print(" ");
                lcd_send_byte(0xCF, 0); 
                lcd_print(" ");
                break;
            case 2:
                if (btn_up) green=green+passo;
                if (btn_dw) green=green-passo;
                t_on = 1;
                //pos LCD C9 com *
                lcd_send_byte(0xC4, 0); 
                lcd_print(" ");
                lcd_send_byte(0xC9, 0); // Coluna 9 (após Green)
                lcd_print("*");
                lcd_send_byte(0xCF, 0); 
                lcd_print(" ");
                break;
            case 3:
                if (btn_up) blue=blue+passo;
                if (btn_dw) blue=blue-passo;
                t_on = 1;
                //pos LCD CF com *
                lcd_send_byte(0xC4, 0); 
                lcd_print(" ");
                lcd_send_byte(0xC9, 0); 
                lcd_print(" ");
                lcd_send_byte(0xCF, 0); // Coluna 15 (após Blue)
                lcd_print("*");
                break;
            default:
                break;
        }
        set_pwm(LED_R, red);
        set_pwm(LED_G, green);
        set_pwm(LED_B, blue);
        
        _delay_ms(100);
    }
}

ISR(TIMER0_OVF_vect){
  if(t_on){
    timer += 1;
    _delay_ms(10);
    // a cada 0,032768 interrupção, 153 até os 5 segundos
    if(timer == 153){
      passo = 25;
    }
    else if (timer == 154){
      t_on = 0;
      timer = 0;
    }
  }
}