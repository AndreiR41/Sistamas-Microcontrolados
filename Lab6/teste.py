import numpy as np
import matplotlib.pyplot as plt
from scipy import signal
from scipy.signal import firwin 
from scipy.signal import freqz


# ================= CONFIGURAÇÕES =================
fs = 270        # Frequência de amostragem (Hz)
fc = 5           # Frequência de corte do filtro (Hz)
numtaps = 16     # Número de coeficientes do filtro
N = 100          # Fator de escala para coeficientes inteiros

# =============== PROJETO DO FILTRO ===============
# Projeta os coeficientes do filtro FIR
coeffs = firwin(numtaps=numtaps, cutoff=fc, fs=fs, window='hamming')
#escalonando os coeficientes
c = np.round(coeffs * N).astype(int)  # Coeficientes escalonados

print("Coeficientes do filtro (escalonados):")
print(coeffs)
print(c)

# ============= GERAÇÃO DO SINAL =============
t = np.arange(0, 1, 1/fs)  # Base de tempo (1 segundo)

# Sinal desejado (5Hz) e interferência (1000Hz)
x_clean = np.sin(2 * np.pi * fc * t)          # Sinal útil
x_interf = 0.5 * np.sin(2 * np.pi * 100 * t) # Ruído
x_adc = x_clean + x_interf                    # Sinal combinado

# Simula conversão ADC (10 bits, 0-1023)
x_adc = np.clip((x_adc + 1) * 512, 0, 1023).astype(np.uint16)             #essa linha pode dar M

# ============= IMPLEMENTAÇÃO DO FILTRO =============
def filtro_fir(x_adc, c, N):
    # Buffer circular (armazena as últimas amostras)
    x = np.zeros(numtaps, dtype=np.uint16)
    indice = 0  # Posição atual no buffer
    y = np.zeros(len(x_adc), dtype=np.uint16)  

    for n in range(len(x_adc)):
        # Atualiza buffer com nova amostra
        x[indice] = x_adc[n]
        
        # Calcula a saída do filtro
        acc = 0
        for i in range(numtaps):
            # Acesso circular aos dados (ordem decrescente)
            idx = (indice + numtaps - i) % numtaps
            acc += x[idx] * c[i]
        
        # Ajustes de escala:
        acc = acc // N  # Remove o fator de escala
        acc = acc >> 2  # Converte 10 bits para 8 bits (divide por 4)
        y[n]=acc
        #y[n] = np.clip(acc, 0, 255)  # Limita a 8 bits
        
        # Atualiza índice (buffer circular)
        indice = (indice + 1) % numtaps
    
    return y

# Aplica o filtro
y = filtro_fir(x_adc, c, N)

# Sinal de referência (8 bits)
x_clean_8bits = np.clip(((x_clean + 1) * 512) // 4, 0, 255)



# ============= VISUALIZAÇÃO =============

w, h = freqz(coeffs)
frequencies = w * fs / (2 * np.pi)  # Converte de rad/sample para Hz

c_escalonado= c/100
w_esc, h_esc = freqz(c_escalonado)
frequencies_esc = w_esc * fs / (2 * np.pi)
# Plot da magnitude
plt.figure()
plt.subplot(2, 1, 1)
plt.plot(frequencies, 20 * np.log10(abs(h)),label='Coeficientes originais')
plt.plot(frequencies,20 * np.log10(abs(h_esc)),label='Coeficientes truncados e escalonados')
plt.title('Resposta em Frequência do Filtro FIR')
plt.xlabel('Frequência (Hz)')
plt.ylabel('Magnitude (dB)')
plt.grid()
plt.legend()

plt.figure(figsize=(12, 8))
# Gráfico 1: Sinal contaminado
plt.subplot(2, 1, 1)
plt.plot(t, x_adc, label='Sinal ADC (10 bits)')
plt.title('Sinal Original com Interferência')
plt.ylabel('Valor ADC')
plt.grid(True)
plt.legend()

# Gráfico 2: Resultado do filtro
plt.subplot(2, 1, 2)
plt.plot(t, x_clean_8bits, 'g--', label='Sinal limpo (referência)')
plt.plot(t, y, 'r', alpha=0.7, label='Sinal filtrado (8 bits)')
plt.title('Desempenho do Filtro FIR')
plt.xlabel('Tempo (s)')
plt.ylabel('Valor (8 bits)')
plt.grid(True)
plt.legend()

plt.tight_layout()
plt.show()