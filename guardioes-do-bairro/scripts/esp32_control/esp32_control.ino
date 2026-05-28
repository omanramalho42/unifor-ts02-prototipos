#include <WiFi.h>

// Definição dos Leds
#define RED_LED 27
#define YELLOW_LED 26  
#define GREEN_LED 14

// Definição dos Botões
#define BTN_RIGHT 19   // MUDOU DO 34 PARA O 19 (Aceita Pull-up interno)
#define BTN_LEFT 33
#define BTN_UP 32
#define BTN_DOWN 18    // MUDOU DO 35 PARA O 18 (Aceita Pull-up interno)
#define BTN_JUMP 25
#define BTN_TAKE 13

const char *ssid = "Cris Pessoa_2G";
const char *pw = "acapp1213";

bool flag_btn_right = 0;
bool flag_btn_left = 0;
bool flag_btn_up = 0;
bool flag_btn_down = 0;
bool flag_btn_take = 0;
bool flag_btn_jump = 0; 

WiFiServer server(80); 

int deBounce(bool estado_atual, int pino_botao) {
  return digitalRead(pino_botao);
}

void setup() {
  pinMode(BTN_RIGHT, INPUT_PULLUP);
  pinMode(BTN_LEFT, INPUT_PULLUP);
  pinMode(BTN_UP, INPUT_PULLUP);
  pinMode(BTN_DOWN, INPUT_PULLUP);
  pinMode(BTN_JUMP, INPUT_PULLUP);
  pinMode(BTN_TAKE, INPUT_PULLUP);

  pinMode(RED_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);

  Serial.begin(115200);
  delay(1000);
  WiFi.begin(ssid, pw);

  while(WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }

  Serial.println("\nConectado");
  Serial.println(WiFi.localIP());
  server.begin();
}

void loop() {
  WiFiClient client = server.available();
  if(client) {
    
    while(client.connected()) {
      
      // --- DIREITA ---
      if(deBounce(flag_btn_right, BTN_RIGHT) == LOW) {
        if(flag_btn_right == 0) {
          flag_btn_right = 1;
          client.print("DIREITA 1\n"); 
        }
      }
      if(flag_btn_right == 1 && deBounce(flag_btn_right, BTN_RIGHT) == HIGH) {
        flag_btn_right = 0;
        client.print("DIREITA 0\n"); // Envia parada
      }

      // --- ESQUERDA ---
      if(deBounce(flag_btn_left, BTN_LEFT) == LOW) {
        if(flag_btn_left == 0) {
          flag_btn_left = 1;
          client.print("ESQUERDA 1\n");
        }
      }
      if(flag_btn_left == 1 && deBounce(flag_btn_left, BTN_LEFT) == HIGH) {
        flag_btn_left = 0;
        client.print("ESQUERDA 0\n"); // Envia parada
      }

      // --- CIMA ---
      if(deBounce(flag_btn_up, BTN_UP) == LOW) {
        if(flag_btn_up == 0) {
          flag_btn_up = 1;
          client.print("UP 1\n");
        }
      }
      if(flag_btn_up == 1 && deBounce(flag_btn_up, BTN_UP) == HIGH) {
        flag_btn_up = 0;
        client.print("UP 0\n"); // CORRIGIDO: Envia comando de parada
      }

      // --- BAIXO ---
      if(deBounce(flag_btn_down, BTN_DOWN) == LOW) {
        if(flag_btn_down == 0) {
          flag_btn_down = 1;
          client.print("BAIXO 1\n"); // Adicionado comando para ir para baixo
        }
      }
      if(flag_btn_down == 1 && deBounce(flag_btn_down, BTN_DOWN) == HIGH) {
        flag_btn_down = 0;
        client.print("BAIXO 0\n"); // CORRIGIDO: Envia comando de parada
      }

      // --- PEGAR (TAKE) ---
      if(deBounce(flag_btn_take, BTN_TAKE) == LOW) {
        if(flag_btn_take == 0) {
          flag_btn_take = 1;
          client.print("TAKE 1\n");
        }
      }
      if(flag_btn_take == 1 && deBounce(flag_btn_take, BTN_TAKE) == HIGH) {
        flag_btn_take = 0;
        client.print("TAKE 0\n"); // Ajustado para limpar a ação se necessário
      }

      // --- PULAR (JUMP) ---
      if(deBounce(flag_btn_jump, BTN_JUMP) == LOW) {
        if(flag_btn_jump == 0) {
          flag_btn_jump = 1;
          client.print("JUMP 1\n");
        }
      }
      if(flag_btn_jump == 1 && deBounce(flag_btn_jump, BTN_JUMP) == HIGH) {
        flag_btn_jump = 0;
        client.print("JUMP 0\n"); // Ajustado para limpar a ação se necessário
      }
      
      // --- LER DADOS VINDOS DA GODOT ---
      while(client.available()) {
        String s = client.readStringUntil('\n');
        s.trim(); 

        if(s == "ON") {
          digitalWrite(GREEN_LED, HIGH);
          digitalWrite(RED_LED, LOW);
        } else if(s == "OFF") {
          digitalWrite(RED_LED, HIGH);
          digitalWrite(GREEN_LED, LOW);
        }
      }
      delay(15);
    }
    client.stop();
    Serial.println("Cliente desconectado");
  }
}