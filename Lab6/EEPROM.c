#include <avr/io.h>
#include <util/delay.h>
// Endereço inicial fixo para o array
#define ENDERECO_INICIAL 0x0000



// Funções básicas da EEPROM (mantidas originais)
void EEPROM_escrever(uint16_t endereco, uint8_t dado);
uint8_t EEPROM_ler(uint16_t endereco);
void EEPROM_escrever_array(uint8_t *dados);
void EEPROM_ler_array(uint8_t *dados);




void EEPROM_escrever(uint16_t endereco, uint8_t dado) {
    while(EECR & (1<<EEPE));
    EEAR = endereco;
    EEDR = dado;
    EECR |= (1<<EEMPE);
    EECR |= (1<<EEPE);
}

uint8_t EEPROM_ler(uint16_t endereco) {
    while(EECR & (1<<EEPE));
    EEAR = endereco;
    EECR |= (1<<EERE);
    return EEDR;
}

// Escreve array de 16 
void EEPROM_escrever_array(uint8_t *dados) {
    for(uint8_t i = 0; i < 16; i++) {
        EEPROM_escrever(ENDERECO_INICIAL + i, dados[i]);
    }
}

// Lê array de 16 
void EEPROM_ler_array(uint8_t *dados) {
    for(uint8_t i = 0; i < 16; i++) {
        dados[i] = EEPROM_ler(ENDERECO_INICIAL + i);
    }
}




