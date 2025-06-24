#include <avr/io.h>
#include <util/delay.h>
#include "LCD.c"  // Certifique-se de que esta biblioteca está corretamente implementada

int main() {
    uint8_t x[8] = {1,2, 3, 1, 2, 3, 4, 5};  // Array de exemplo
    uint8_t y[8] = {3, 6, 7, 7, 8, 1, 2, 7};

    lcd_init();
    lcd_print("X");  // Primeira linha (título)
    lcd_send_byte(0xC0, 0);  
    lcd_print("Y"); 

    while (1) {
        lcd_send_byte(0x81, 0);  
        // Loop para exibir cada elemento do array
        for (uint8_t i = 0; i < 8; i++) {
            char num_str[4];  // Buffer para converter o número em string
            ident_num(x[i], num_str, 2); // diminui o tamanho pra exibir 1 casa
            lcd_print(num_str);

            // Adiciona espaço entre os números (exceto após o último)
            if (i < 7) {
                lcd_print(" ");
            }
        }
        lcd_send_byte(0xC1, 0);  
        // Loop para exibir cada elemento do array
        for (uint8_t i = 0; i < 8; i++) {
            char num_str[4];  // Buffer para converter o número em string
            ident_num(y[i], num_str, 2); // diminui o tamanho pra exibir 1 casa
            lcd_print(num_str);

            // Adiciona espaço entre os números (exceto após o último)
            if (i < 7) {
                lcd_print(" ");
            }
        }



        _delay_ms(500);
    }
}