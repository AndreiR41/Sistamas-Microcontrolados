#include <avr/io.h>
#include <util/delay.h>

void initADC();
uint16_t readADC(uint8_t channel);


// Configura o ADC (Conversor Analógico-Digital)
void initADC() {
    ADMUX  |= (1 << REFS0);  // Tensão de referência AVcc (5V)
    ADCSRA |= (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);  // Habilita ADC e prescaler 128-> clock = 125kHz
}

// Lê um canal ADC (0-5V -> 0-1023)
uint16_t readADC(uint8_t channel) {
    ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);  // Seleciona o canal
    ADCSRA |= (1 << ADSC);  // Inicia conversão
    while (ADCSRA & (1 << ADSC));  // Aguarda fim da conversão   // espera a flag de conclusao
    return ADC;  // Retorna o valor lido (10 bits)
}

