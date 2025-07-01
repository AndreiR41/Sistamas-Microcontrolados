#include <avr/io.h>
#include <util/delay.h>



/*
 * Tabela de cosseno de 128 amostras, centrada em 128
 * Representa um ciclo completo com resolução de 8 bits
 */
const uint8_t cos_table[128] = {
	255, 254, 254, 253, 252, 250, 248, 246,
	244, 241, 238, 235, 231, 228, 224, 220,
	216, 211, 207, 202, 197, 192, 187, 181,
	176, 170, 165, 159, 153, 147, 141, 135,
	129, 123, 117, 111, 105,  99,  93,  87,
	82,  76,  71,  66,  61,  56,  52,  47,
	43,  39,  36,  32,  29,  26,  24,  21,
	19,  17,  16,  14,  13,  12,  12,  11,
	11,  11,  12,  12,  13,  14,  16,  17,
	19,  21,  24,  26,  29,  32,  36,  39,
	43,  47,  52,  56,  61,  66,  71,  76,
	82,  87,  93,  99, 105, 111, 117, 123,
	129, 135, 141, 147, 153, 159, 165, 170,
	176, 181, 187, 192, 197, 202, 207, 211,
	216, 220, 224, 228, 231, 235, 238, 241,
	244, 246, 248, 250, 252, 253, 254, 254
};

static uint8_t indice_cos = 0;

// ---------------------- AM ----------------------
uint8_t modulacao_am(uint8_t x) {
    int16_t cos_bipolar = (int16_t)cos_table[indice_cos] - 128; // agora varia de -128 a +127
    int16_t produto = ((int16_t)x * cos_bipolar) >> 8;                 // resultado varia de -32768 a +32512
    // Escala de volta para -127 a +127 e soma 128 para centrar
    int16_t y = produto + 127;

    indice_cos = (indice_cos + 1) % 128;
    return (uint8_t)y;
}


// ---------------------- FM ----------------------
uint8_t modulacao_fm(uint8_t x) {
    uint8_t incremento = 1 + (x >> 6); 
    indice_cos = (indice_cos + incremento) % 128;
    return cos_table[indice_cos];
}

// ---------------------- ASK ----------------------
uint8_t modulacao_ask(uint8_t x) {
  uint8_t y = 0;
  uint8_t count_bits = 0;
  uint8_t bits_ask = 0;

    if (count_bits == 0) {
        bits_ask = x;
        count_bits = 8;
    }

    uint8_t bit_atual = bits_ask & 0x01; // extrai o bit menos significativo

    if (bit_atual) {
        y = cos_table[indice_cos];
    } else {
        y = 128;
    }

    indice_cos++;
    if (indice_cos >= 128) {
        indice_cos = 0;
        bits_ask >>= 1;    // avança para o próximo bit
        count_bits--;
    }
    return y;

}

// ---------------------- FSK ----------------------
uint8_t modulacao_fsk(uint8_t x) {
   uint8_t y = 0;
   uint8_t count_bits = 0;
   uint8_t bits_fsk = 0;
   uint8_t incremento =0;

     if (count_bits == 0) {
        bits_fsk = x  ;
        count_bits = 8;
    }
    uint8_t bit_atual = bits_fsk & 0x01;
    if(bit_atual){
      incremento =12;
    }
    else{
      incremento =1;
    }
    indice_cos = indice_cos+ incremento;
    y=cos_table[indice_cos];

    if (indice_cos >= 128) {
        indice_cos = 0;
        bits_fsk >>= 1;    // avança para o próximo bit
        count_bits--;
    }

  return y;
}



