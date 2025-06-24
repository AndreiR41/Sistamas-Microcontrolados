#include <avr/io.h>
#include <util/delay.h>

#include "ADC.c"
#include "LCD.c"

#define Analog0 PC0  // Pino A0



int main(void) {
    initADC();
    lcd_init();

    lcd_print("ADC");
    lcd_send_byte(0xC0, 0);
    lcd_print("C:");

    uint16_t adc_value;
    uint16_t x[16] = {0};
    uint8_t indice = 0;

    while (1) {
        adc_value = readADC(Analog0);

      
      

        lcd_send_byte(0xC4, 0);
        char adc_str[6];
        ident_num(adc_value, adc_str, 5);
        lcd_print(adc_str);

        _delay_ms(100);
    }
}


