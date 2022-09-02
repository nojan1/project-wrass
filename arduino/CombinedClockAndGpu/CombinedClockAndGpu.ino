
#define CLOCK_IN 2
#define CLOCK_OUT 3

#define READ_WRITE 4
#define AUTO_CLOCK 5
#define SINGLE_STEP_CLOCK 6
#define GPU_CS 7
#define MODE 8

//const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
const char ADDR[] = {52, 50, 48, 46, 44, 42, 40, 38, 36, 34, 32, 30, 28, 26, 24, 22};

//const char DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};
const char DATA[] = {53, 51, 49, 47, 45, 43, 41, 39};

char mode = 0;

void setup() {
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);
  pinMode(GPU_CS, INPUT);
  pinMode(CLOCK_OUT, OUTPUT);
  pinMode(MODE, INPUT);
  pinMode(AUTO_CLOCK, INPUT);
  pinMode(SINGLE_STEP_CLOCK, INPUT);

  for(int n = 0; n < 6; n++)
  {
    pinMode(ADDR[n], INPUT);  
  }

  resetDatabus();

  Serial.begin(115200);

  mode = digitalRead(MODE);

  if(mode == HIGH)
    setupGPU();
  else
    setupClock();
}

void loop() {
  if(mode == HIGH)
    loopGPU();


   loopClock();
}

/// CLOCK ////

void setupClock() {
  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), readBusesClock, RISING);
  Serial.println("Bus monitor activated");
}


void loopClock() {
  if(digitalRead(AUTO_CLOCK) == 1){
    emitPulse();
    delay(1);            
  }else if(digitalRead(SINGLE_STEP_CLOCK) == 1){
      emitPulse();
      delay(300);  
  }
}

void emitPulse(){
  digitalWrite(CLOCK_OUT, HIGH);   
  delay(1);                    
  digitalWrite(CLOCK_OUT, LOW);   
}

void readBusesClock(){
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

/// GPU ////

unsigned int col = 0;
unsigned int row = 0;

unsigned int registers[] = {0, 0, 0, 1, 0, 0xC0, 0};

const char sendBuffer[10][15] = {};
unsigned int currentSend = 0;
unsigned int currentWrite = 0;

void setupGPU() {
  resetDatabus();

  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), readBusesGPU, RISING);
  //attachInterrupt(digitalPinToInterrupt(CLOCK_IN), resetDatabus, FALLING);

    Serial.println("GPU mode activated");
}

void loopGPU() {
  // put your main code here, to run repeatedly:
  if(currentSend != currentWrite) {
    currentSend = (currentSend + 1) % 10;
    Serial.write(sendBuffer[currentSend]);
  }
}

void resetDatabus() {
  for(int x = 0; x < 8; x++){
    pinMode(DATA[x], INPUT);
  }
}

void readBusesGPU(){
  if(digitalRead(GPU_CS) == HIGH) return;
  
  unsigned int address = 0;
  for (int n = 0; n < 6; n += 1) {
    int bit = digitalRead(ADDR[n]) ? 1 : 0;
    address = (address << 1) + bit;
  }
  
  if(digitalRead(READ_WRITE) == HIGH){
    // Read operation 
    if(address == 6) {
      output(0); // No real VRAM to read from
    }else{
      output(registers[address % 6]);
    } 
  }else{
    // Write operation  
    unsigned int data = 0;
    for (int n = 0; n < 8; n += 1) {
      int bit = digitalRead(DATA[n]) ? 1 : 0;
      data = (data << 1) + bit;
    }

    if(address == 6) {
      unsigned int memoryAddress = getMemoryAddress();

      if(memoryAddress >= 0xC000 && memoryAddress <= 0xD2C0) {
        // In the framebuffer region
        memoryAddress -= 0xC000;

        unsigned int writeCol = memoryAddress % 80;
        unsigned int writeRow = memoryAddress / 80;

        int tempCurrentSend = (currentSend + 1) % 10;

        if(writeRow != row || writeCol != col + 1) {
          // We have moved.. need to set cursor position
          /*Serial.write(0x1B);
          Serial.print("[");
          Serial.print(writeRow);
          Serial.print(";");
          Serial.print(writeCol);
          Serial.print("H");*/

          tempCurrentSend = (currentSend + 1) % 10;
          sprintf(sendBuffer[tempCurrentSend], "%c[%i;%iH", 0x1B, writeRow, writeCol);
          
        }  

        sprintf(sendBuffer[tempCurrentSend], "%c", data);
        currentSend = tempCurrentSend;
        
        col = writeCol;
        row = writeRow;
      }

      registers[4] += registers[6];
      if(registers[4] >= 256) {
        registers[4] -= 255;
        registers[5]++;  
      }
    }else{
      registers[address % 6] = data;  

      /*char output[20];
      sprintf(output, "Got register write  %04x  %02x", address, data);
      Serial.println(output);  */
    }
  }
}

void output(unsigned int data) {
   int tempCurrentSend = (currentSend + 1) % 10;
   sprintf(sendBuffer[tempCurrentSend], "Attempting to output %02x", data);
   currentSend = tempCurrentSend;
  return;
  
  for(int x = 0; x < 8; x++){
    pinMode(DATA[x], OUTPUT);
    digitalWrite(DATA[x], (data << x) & 1 ? HIGH : LOW);
  }
}

unsigned int getMemoryAddress() {
  return (registers[5] << 8) + registers[4];
}
