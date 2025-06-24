#include <avr/io.h>
#include <util/delay.h>

// Definições dos pinos (ajuste conforme seu microcontrolador)
#define VRX_PIN PC4      // Pino A4 (PC4 no ATmega328P)
#define VRY_PIN PC5      // Pino A5 (PC5 no ATmega328P)
#define SW_PIN  PD2       // Pino digital 2 (PD2 no ATmega328P)

// Protótipos das funções
void initADC();
uint16_t readADC(uint8_t channel);
void initDigitalInput();

// TESTE

int main(void) {
    // Inicializações
    initADC();
    initDigitalInput();
    // Que me atirem a primeira pedra, vai no Monitor serial mesmo!
    Serial.begin(9600);

    // Loop principal
    while (1) {
        uint16_t leitura_VRX = readADC(VRX_PIN);  // Lê VRX (A4)
        uint16_t leitura_VRY = readADC(VRY_PIN);  // Lê VRY (A5)
        uint8_t leitura_botao = (PIND & (1 << SW_PIN)) ? 0 : 1;  // Lê SW (PD2, pull-up)

        Serial.print("VRX: "); Serial.print(leitura_VRX);
        Serial.print("\tVRY: "); Serial.print(leitura_VRY);
        Serial.print("\tBotao: "); Serial.println(leitura_botao);

        _delay_ms(10);  // Pequeno atraso
    }
}

// QUE NEGOCIO LINDO ADC EM C
// Configura o ADC (Conversor Analógico-Digital)
void initADC() {
    ADMUX  |= (1 << REFS0);  // Tensão de referência AVcc (5V)
    ADCSRA |= (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);  // Habilita ADC e prescaler 128
}

// Lê um canal ADC (0-5V -> 0-1023)
uint16_t readADC(uint8_t channel) {
    ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);  // Seleciona o canal
    ADCSRA |= (1 << ADSC);  // Inicia conversão
    while (ADCSRA & (1 << ADSC));  // Aguarda fim da conversão
    return ADC;  // Retorna o valor lido (10 bits) o HIGH E LOW juntos
}

// Configura pino digital como entrada com pull-up
// O Botão do Joystick
void initDigitalInput() {
    DDRD &= ~(1 << SW_PIN);   // Define PD2 como entrada
    PORTD |= (1 << SW_PIN);   // Ativa pull-up interno
} 