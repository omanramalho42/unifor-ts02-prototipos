// Definição dos pinos dos Botões
const int PIN_ESQUERDA = 33;
const int PIN_FRENTE   = 32;
const int PIN_DIREITA  = 35;
const int PIN_PULO     = 25;
const int PIN_ITEM     = 13;

// Definição dos pinos dos LEDs
const int LED_1 = 12;
const int LED_2 = 14;
const int LED_3 = 27;

// Variáveis para controle de tempo (Debounce simples)
unsigned long ultimoTempo = 0;
const int intervalo = 20; // Envia dados a cada 20ms

void setup() {
  // Inicializa a comunicação Serial
  Serial.begin(115200);

  // Configuração dos pinos dos botões como Entrada com Pull-up interno
  pinMode(PIN_ESQUERDA, INPUT_PULLUP);
  pinMode(PIN_FRENTE, INPUT_PULLUP);
  pinMode(PIN_DIREITA, INPUT_PULLUP);
  pinMode(PIN_PULO, INPUT_PULLUP);
  pinMode(PIN_ITEM, INPUT_PULLUP);

  // Configuração dos LEDs como Saída
  pinMode(LED_1, OUTPUT);
  pinMode(LED_2, OUTPUT);
  pinMode(LED_3, OUTPUT);
}

// Variáveis para guardar o estado anterior (evita inundar a tela com texto repetido)
int antEsq = 0, antFre = 0, antDir = 0, antPul = 0, antItm = 0;
void loop() {
  // Lendo os estados atuais (1 = Pressionado, 0 = Solto)
  int esq = !digitalRead(PIN_ESQUERDA);
  int fre = !digitalRead(PIN_FRENTE);
  int dir = !digitalRead(PIN_DIREITA);
  int pul = !digitalRead(PIN_PULO);
  int itm = !digitalRead(PIN_ITEM);

  // Atualiza os LEDs fisicamente (eles continuam acendendo enquanto segurar e apagando ao soltar)
  digitalWrite(LED_1, esq);
  digitalWrite(LED_2, fre);
  digitalWrite(LED_3, dir);

  // VARIÁVEL DE CONTROLE: Só entra aqui se um botão foi PRESSIONADO (mudou de 0 para 1)
  bool mudouParaPressionado = (esq && !antEsq) || (fre && !antFre) || (dir && !antDir) || (pul && !antPul) || (itm && !antItm);

  if (mudouParaPressionado) {
    
    Serial.println("--- BOTÃO PRESSIONADO ---");
    
    // Só mostra o botão específico que foi apertado neste instante
    if (esq && !antEsq) Serial.println("-> ESQUERDA foi pressionado!");
    if (fre && !antFre) Serial.println("-> FRENTE foi pressionado!");
    if (dir && !antDir) Serial.println("-> DIREITA foi pressionado!");
    if (pul && !antPul) Serial.println("-> PULO foi pressionado!");
    if (itm && !antItm) Serial.println("-> ITEM (F) foi pressionado!");
    
    Serial.println("-------------------------\n");
    
    delay(50); // Delay para debounce (evitar cliques fantasmas)
  }

  // Atualiza sempre o estado anterior para a próxima verificação (seja soltando ou apertando)
  antEsq = esq;
  antFre = fre;
  antDir = dir;
  antPul = pul;
  antItm = itm;
}