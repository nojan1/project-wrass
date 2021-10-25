
#define CLOCK_IN 2
#define CLOCK_OUT 3
#define READ_WRITE 4

const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 50};
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};

// the setup function runs once when you press reset or power the board
void setup() {
  pinMode(CLOCK_OUT, OUTPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);

  for(int n = 0; n < 16; n++)
  {
    pinMode(ADDR[n], INPUT);  
  }

  for(int x = 0; x < 8; x++){
    pinMode(DATA[x], INPUT);
  }

  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), readBuses, RISING);

  Serial.begin(57600);
}

// the loop function runs over and over again forever
void loop() {
  emitPulse();
  delay(200);             
}

void emitPulse(){
  digitalWrite(CLOCK_OUT, HIGH);   
  //delay(10);                      
  digitalWrite(CLOCK_OUT, LOW);   
  delay(10);

  readBuses();
}

void readBuses(){
  unsigned int address = 0;
  unsigned int data = 0;
  char output[15];
  
  for(int n = 0; n < 16; n++){
    int bit = digitalRead(ADDR[n]) ? 1 : 0;
    Serial.print(bit);
    address |= bit << n;
  }

  Serial.print("  ");
  
  for(int n = 0; n < 8; n++){
    int bit = digitalRead(DATA[n]) ? 1 : 0;
    Serial.print(bit);
    data |= bit << n;
  }

  sprintf(output, "  %04x  %c %02x", address, digitalRead(READ_WRITE) ? 'r' : 'W', data);
  Serial.println(output);
}
