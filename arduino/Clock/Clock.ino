
#define CLOCK_IN 2
#define CLOCK_OUT 3
#define READ_WRITE 4
#define AUTO_CLOCK 5
#define SINGLE_STEP_CLOCK 6

const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 50};
const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};

// the setup function runs once when you press reset or power the board
void setup() {
  pinMode(CLOCK_OUT, OUTPUT);
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);
  pinMode(AUTO_CLOCK, INPUT);
  pinMode(SINGLE_STEP_CLOCK, INPUT);

  for(int n = 0; n < 16; n++)
  {
    pinMode(ADDR[n], INPUT);  
  }

  for(int x = 0; x < 8; x++){
    pinMode(DATA[x], INPUT);
  }

  //attachInterrupt(digitalPinToInterrupt(CLOCK_IN), readBuses, RISING);

  Serial.begin(57600);
}

// the loop function runs over and over again forever
void loop() {
  if(digitalRead(AUTO_CLOCK) == 1){
    emitPulse();
    delay(50);             
  }else if(digitalRead(SINGLE_STEP_CLOCK) == 1){
      emitPulse();
      delay(300);  
  }
}

void emitPulse(){
  digitalWrite(CLOCK_OUT, HIGH);   
  delay(1);                      
  digitalWrite(CLOCK_OUT, LOW);   

  readBuses();
}

void readBuses(){
  char output[15];

  unsigned int address = 0;
  for (int n = 0; n < 16; n += 1) {
    int bit = digitalRead(ADDR[n]) ? 1 : 0;
    Serial.print(bit);
    address = (address << 1) + bit;
  }
  
  Serial.print("   ");
  
  unsigned int data = 0;
  for (int n = 0; n < 8; n += 1) {
    int bit = digitalRead(DATA[n]) ? 1 : 0;
    Serial.print(bit);
    data = (data << 1) + bit;
  }

  sprintf(output, "   %04x  %c %02x", address, digitalRead(READ_WRITE) ? 'r' : 'W', data);
  Serial.println(output);  
}
