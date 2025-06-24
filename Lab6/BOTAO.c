
#include <avr/io.h>
#include <util/delay.h>

#define BTN_M   PC1  // A1 (PC1)
#define BTN_UP  PC2  // A2 (PC2)
#define BTN_DW  PC3  // A3 (PC3)

void setup_botao();

void setup_botao(){
    // Configura os pinos dos botões como entrada (PC1, PC2, PC3 = A1, A2, A3 no Arduino)
    DDRC &= ~((1 << PC1) | (1 << PC2) | (1 << PC3));

    // Ativa o pull-up interno nos pinos dos botões
    PORTC |= (1 << PC1) | (1 << PC2) | (1 << PC3);
}


