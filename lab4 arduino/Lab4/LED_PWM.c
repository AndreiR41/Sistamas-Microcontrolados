#include <util/delay.h>
#include "LED_PWM.h"

void setup_pwm() {
    //COM ativa as saídas , WGM (waveform generation mode)configura o PWM do timer como rrapido
    // Configura Timer1 (10-bit PWM para LED_G e LED_B)
    TCCR1A = (1 << COM1A1) | (1 << COM1B1) | (1 << WGM11) | (1 << WGM10);
    TCCR1B = (1 << CS10); // Prescaler 1 (PWM freq ~31.25 kHz)
    
    // Configura Timer2 (8-bit PWM para LED_R)
    TCCR2A = (1 << COM2A1) | (1 << WGM20) | (1 << WGM21);
    TCCR2B = (1 << CS20); // Prescaler 1 (PWM freq ~31.25 kHz)
    
   // Configura os pinos dos LEDs como saída (PB1, PB2, PB3 = pinos 9, 10, 11 no Arduino)
    DDRB |= (1 << PB1) | (1 << PB2) | (1 << PB3);

    // Configura os pinos dos botões como entrada (PC1, PC2, PC3 = A1, A2, A3 no Arduino)
    DDRC &= ~((1 << PC1) | (1 << PC2) | (1 << PC3));

    // Ativa o pull-up interno nos pinos dos botões
    PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3);
}

void set_pwm(uint8_t led, uint8_t valor) {
    switch (led) {
        case LED_R:
            OCR2A = valor;
            break;
        case LED_G:
            OCR1B = valor;
            break;
        case LED_B:
            OCR1A = valor;
            break;
    }
}