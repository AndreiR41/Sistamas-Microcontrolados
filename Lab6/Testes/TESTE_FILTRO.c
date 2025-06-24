#include "FILTRO.c"

#include <stdio.h>
#include <stdint.h>

// y[n] = sum(h[k] * x[n - k] for k in range(N)) #FIR

int main() {
    int x[] = {1, 2, 3};  // Sinal de entrada
    int h[] = {1, 2, 1};  // Resposta ao impulso
    
    int M = sizeof(x) / sizeof(x[0]);
    int N = sizeof(h) / sizeof(h[0]);
    int L = M + N - 1;    // Tamanho do vetor de saída
    int y[L];             // Vetor de saída

    conv(x, M, h, N, y);
    

    //================EXIBICAO============
    printf("Resultado da convolução inteira:\n");
    for (int i = 0; i < M; i++) {
        printf("y[%d] = %d\n", i, y[i]);
    }
    
    return 0;
}
// multiplicar coeficientes de h *100float->int
//dividir y por 100 quando converter para 10 bits
//dividir y/4 para 10bits->8bits ~~ // aka 2 deslocamento a direita
// Fs = 9600 bauds -> Fnyquist = Fs/2