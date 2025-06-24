#include <avr/io.h>
#include <util/delay.h>
#include "EEPROM.c"
#include "LCD.c"

int main() {
    uint8_t array[16] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
    uint8_t memoria[16];
    
    // Armazenar array   	COMENTA E MUDA ARRAY P TESTE
    EEPROM_escrever_array(array);
    
    // Recuperar dados
    EEPROM_ler_array(memoria);
    
	lcd_init();
    lcd_print("Coeficiente");

    while(1) {
		lcd_send_byte(0xC0, 0);
        lcd_print("Memoria: ");
        // Formata e exibe o  atual
        char indice_str[4];
        ident_num(memoria[0], indice_str, 4);  
        lcd_print(indice_str);
        
}
    return 0;
}