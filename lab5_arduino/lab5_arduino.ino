#include <avr/io.h>
#include <util/delay.h>
#include "LCD.c"  
#include "Joystick.c"
#include "Matriz.c"



 // MDE
    typedef enum {
    UP,
    DW,
    LEFT,
    RIGHT
} Estado;

// declarando funções main
void exibirXY(uint8_t x[], uint8_t y[]);
void mover_cobra(uint8_t x[], uint8_t y[], uint8_t tamanho, Estado estado_atual);
uint8_t colisao(uint8_t x[], uint8_t y[]);
void restart(uint8_t x[], uint8_t y[], Estado estado_atual);
void morreu();

void crescer(uint8_t x[], uint8_t y[],uint8_t tamanho_cobra);

void meu_delay_ms(int ms);


 
uint8_t tamanho_cobra = 1;
int delay_atual = 500;

int main() {
  // inicializa a cobra
    uint8_t x[8] = {4, 0, 0, 0, 0,0,0,0 };  
    uint8_t y[8] = {4, 0, 0, 0, 0,0,0,0 };

    int tempo_decorrido = 0;
    

    

    // Inicializações
    lcd_init();
    lcd_print("X");  // Primeira linha (título)
    lcd_send_byte(0xC0, 0);  
    lcd_print("Y"); 
    // Inicializações
    max7219_init();
    max7219_clear();

    // Inicializações
    initADC();
    
    // Que me atirem a primeira pedra, vai no Monitor serial mesmo!
    Serial.begin(9600);

  
Estado estado_atual = RIGHT;

    while (1) {
        //exibindo no LCD
        exibirXY(x, y);
       
        byte matriz[8];
        exibirCobra(x,y,matriz);
        
        
        
        // ler ADC
        uint16_t leitura_VRX = readADC(VRX_PIN);  // Lê VRX (A4)
        uint16_t leitura_VRY = readADC(VRY_PIN);  // Lê VRY (A5)
        
        Serial.print("VRX: "); Serial.print(leitura_VRX);
        Serial.print("\tVRY: "); Serial.print(leitura_VRY);

      if(leitura_VRX < 300 && estado_atual != LEFT){
          estado_atual = RIGHT;
      }
      if(leitura_VRX > 600 && estado_atual != RIGHT){
          estado_atual = LEFT;
      }
      if(leitura_VRY < 300 && estado_atual != UP){
          estado_atual = DW;
      }
      if(leitura_VRY > 600 && estado_atual != DW){
          estado_atual = UP;
}

        uint8_t tamanho = sizeof(x) / sizeof(x[0]);
        mover_cobra(x, y, tamanho, estado_atual);
        // AUMENTAR DIFICULDADE a cada 60000ms
        meu_delay_ms(delay_atual); // fazer o proprio para modificar
        tempo_decorrido +=delay_atual;

        if(tempo_decorrido >= 600){                        //AQUI                             
          tempo_decorrido = 0;
          if (delay_atual > 100) {
              delay_atual -= 50;
            }
          crescer(x, y,tamanho_cobra);
          tamanho_cobra++;
        }

        if(colisao(x,y)){
          morreu();
          restart(x,y,estado_atual);
          } 

        }



    }


void exibirXY(uint8_t x[], uint8_t y[]){
    lcd_send_byte(0x81, 0);  
    for (uint8_t i = 0; i < 8; i++) {
        char num_str[4];
        ident_num(x[i], num_str, 2);
        lcd_print(num_str);
        if (i < 7) {
            lcd_print(" ");
        }
    }
    lcd_send_byte(0xC1, 0);  
    for (uint8_t i = 0; i < 8; i++) {
        char num_str[4];
        ident_num(y[i], num_str, 2);
        lcd_print(num_str);
        if (i < 7) {
            lcd_print(" ");
        }
    }
}


void mover_cobra(uint8_t x[], uint8_t y[], uint8_t tamanho, Estado estado_atual) {
    uint8_t x_temp[tamanho];
    uint8_t y_temp[tamanho];

      // Copia os valores atuais de x e y para os temporários
    for (uint8_t i = 0; i < tamanho; i++) {
        x_temp[i] = x[i];
        y_temp[i] = y[i];
    }

    // Mover a cabeça
    switch (estado_atual) {
        case UP:    
          y[0]++; 
        break;

        case DW:    
          y[0]--; 
        break;

        case LEFT:  
          x[0]--; 
        break;

        case RIGHT: 
          x[0]++; 
        break;
    }

    // Move o corpo: 
    for (uint8_t i = 1; i < tamanho; i++) {
      if(x[i]!=0){ x[i] = x_temp[i - 1];}
       
      if(y[i]!=0){y[i] = y_temp[i - 1];}
        
    }
}

uint8_t colisao(uint8_t x[], uint8_t y[]) {
    // fora da matriz
    if (x[0] > 8  || y[0] > 8) return 1;

    // Colisão 
    for (uint8_t i = 1; i < 8; i++) {
        if (x[0] == x[i] && y[0] == y[i]) 
          return 1;
    }
    return 0;
}

void restart(uint8_t x[], uint8_t y[], Estado estado_atual) {
    // Reinicia 
    x[0] = 4; y[0] = 4;
    for (uint8_t i = 1; i < 8; i++) {
        x[i] = 0; 
        y[i] = 0;  // Zera 
    }
    estado_atual = RIGHT;  
    tamanho_cobra = 1;
    delay_atual =500;
}

void crescer(uint8_t x[], uint8_t y[],uint8_t tamanho_cobra){
  if (tamanho_cobra < 8) {  
       
        x[tamanho_cobra] = x[tamanho_cobra - 1]-1;
        y[tamanho_cobra] = y[tamanho_cobra - 1];
  }
}

void morreu(){
    max7219_send(0x01, 0b00000000);
    max7219_send(0x02, 0b11000011);
    max7219_send(0x03, 0b11000011);
    max7219_send(0x04, 0b00111100);
    max7219_send(0x05, 0b01100110);
    max7219_send(0x06, 0b11000011);
    max7219_send(0x07, 0b11000011);
    max7219_send(0x08, 0b00000000);
    _delay_ms(1000);
    max7219_send(0x01, 0b00000000);
    max7219_send(0x02, 0b11000011);
    max7219_send(0x03, 0b11000011);
    max7219_send(0x04, 0b00111100);
    max7219_send(0x05, 0b11000011);
    max7219_send(0x06, 0b11000011);
    max7219_send(0x07, 0b00111100);
    max7219_send(0x08, 0b00000000);
    _delay_ms(1000);
}

void meu_delay_ms(int ms) {
    while (ms--) {
        _delay_ms(1);
    }
}