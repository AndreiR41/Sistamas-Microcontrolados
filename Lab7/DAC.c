#include <avr/io.h>
#include <util/delay.h>

void initDAC() {
    // Configura PB0 a PB5 como saída (D8 a D13)
    DDRB |= (1 << PB0) | (1 << PB1) | (1 << PB2) | (1 << PB3) | (1 << PB4) | (1 << PB5);
    // Configura PC4 e PC5 como saída (A4, A5)
    DDRC |= (1 << PC4) | (1 << PC5);
}

void fazerDAC(uint8_t value) {
    PORTC=(value<<4)& 0x30;
    PORTB=(value>>2);
    
}



