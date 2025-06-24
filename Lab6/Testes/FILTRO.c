#include <avr/io.h>
#include <util/delay.h>

void conv(uint16_t x[], uint8_t  M, uint8_t h[], uint8_t  N, uint16_t  y[]);

// y[n] = sum(h[k] * x[n - k] for k in range(N)) #FIR

void conv(uint16_t x[], uint8_t  M, uint8_t h[], uint8_t  N, uint16_t  y[]) {
    int L = M + N - 1;  // Tamanho do sinal de saída
    //L = M+N-1 tamanho máximo
    //M= tamanho x, N tamanho coeficientes
    for (int k = 0; k < M; k++) {
        int acc = 0;// acumulador, quando K menor que tamanho total inicia

        for (int i = 0; i < N; i++) {
            int idx = k - i;  // Índice x(k-i)
            if (idx >= 0 && idx < M) {
        // multiplica pelo coeficiente(i) de h
                acc += h[i] * x[idx]; 
            }
        }
        y[k] = acc;// armazena no valor k de y
    }
}