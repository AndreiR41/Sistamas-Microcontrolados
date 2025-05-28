#ifndef LED_PWM_H
#define LED_PWM_H

#include <avr/io.h>



// Definição dos pinos (conforme datasheet ATmega328P)
#define LED_R   PB3  // OC2A (Pino 11 no Arduino)
#define LED_G   PB2  // OC1B (Pino 10 no Arduino)
#define LED_B   PB1  // OC1A (Pino 9 no Arduino)
#define BTN_M   PC1  // A1 (PC1)
#define BTN_UP  PC2  // A2 (PC2)
#define BTN_DW  PC3  // A3 (PC3)

// Protótipos das funções
void setup_pwm(void);
void set_pwm(uint8_t led, uint8_t valor);

#endif // LED_PWM_H