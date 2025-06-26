#include <avr/io.h>
#include <util/delay.h>

void initDAC() {
    // Configura PB0 a PB5 como saída (D8 a D13)
    DDRB |= (1 << PB0) | (1 << PB1) | (1 << PB2) | (1 << PB3) | (1 << PB4) | (1 << PB5);
    // Configura PC4 e PC5 como saída (A4, A5)
    DDRC |= (1 << PC4) | (1 << PC5);
}

void fazerDAC(uint8_t value) {
   //jeito MUITO melhor de André
    PORTC=(value<<4)& 0x30;
    PORTB=(value>>2);
    /*
    // D13 (PB5) = bit 7
    if(value & 0b10000000) PORTB |= (1 << PB5);
    else PORTB &= ~(1 << PB5);
    
    // D12 (PB4) = bit 6
    if(value & 0b01000000) PORTB |= (1 << PB4);
    else PORTB &= ~(1 << PB4);
    
    // D11 (PB3) = bit 5
    if(value & 0b00100000) PORTB |= (1 << PB3);
    else PORTB &= ~(1 << PB3);
    
    // D10 (PB2) = bit 4
    if(value & 0b00010000) PORTB |= (1 << PB2);
    else PORTB &= ~(1 << PB2);
    
    // D9 (PB1) = bit 3
    if(value & 0b00001000) PORTB |= (1 << PB1);
    else PORTB &= ~(1 << PB1);
    
    // D8 (PB0) = bit 2
    if(value & 0b00000100) PORTB |= (1 << PB0);
    else PORTB &= ~(1 << PB0);
    
    // A5 (PC5) = bit 1
    if(value & 0b00000010) PORTC |= (1 << PC5);
    else PORTC &= ~(1 << PC5);
    
    // A4 (PC4) = bit 0
    if(value & 0b00000001) PORTC |= (1 << PC4);
    else PORTC &= ~(1 << PC4);
    */
}



