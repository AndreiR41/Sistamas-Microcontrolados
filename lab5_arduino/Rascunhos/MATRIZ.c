#include <stdio.h>

typedef unsigned char byte;

void preenchermatriz( int x[], int y[], byte matriz[]){
    // Zera tudo 
    for (int i =0; i<8 ;i++){
        matriz[i]= 0;
    }
    // seta de acordo com as pos de x e y
    for (int i =0; i<8;i++){
        // ou com mascara pos x
        matriz[y[i]] |= (1<< x[i]);
    }
}

void imprimirMatriz(byte matriz[]) {
    for (int i = 0; i < 8; i++) {       // Para cada linha (0 a 7)
        for (int j = 7; j >= 0; j--) {  // Bits: do MSB (j=7) para o LSB (j=0)
            // Verifica se o bit j está setado
            if (matriz[i] & (1 << j)) {
                printf("1 ");
            } else {
                printf("0 ");
            }
        }
        printf("\n"); // Nova linha após cada byte
    }
}

