
#include <avr/io.h>
#include <util/delay.h>

#define BTN_M   PC1  // A1 (PC1)
#define BTN_UP  PC2  // A2 (PC2)
#define BTN_DW  PC3  // A3 (PC3)

void setup_botao();




//==================================funções==============

void setup_botao(){
    // Configura pinos como entrada com pull-up
    DDRC  &= ~((1 << BTN_M) | (1 << BTN_UP) | (1 << BTN_DW));
    PORTC |=  (1 << BTN_M) | (1 << BTN_UP) | (1 << BTN_DW);

    // Habilita interrupções Pin Change na porta C
    PCICR  |= (1 << PCIE1);      // Habilita PCINT para PORTC
    PCMSK1 |= (1 << PCINT9) |    // PC1 (BTN_M) corresponde a PCINT9
              (1 << PCINT10) |   // PC2 (BTN_UP) corresponde a PCINT10
              (1 << PCINT11);    // PC3 (BTN_DW) corresponde a PCINT11
    sei();                       // Habilita interrupções globais
}




