#define CLOCK_IN 2
#define READ_WRITE 4
#define CS 5

const char ADDR[] = {52, 50, 48, 46, 44, 42};
const char DATA[] = {53, 51, 49, 47, 45, 43, 41, 39};

unsigned int col = 0;
unsigned int row = 0;

unsigned int registers[] = {0, 0, 0, 1, 0, 0xC0, 0};

const char sendBuffer[10][15] = {};
unsigned int currentSend = 0;
unsigned int currentWrite = 0;

void setup() {
  pinMode(READ_WRITE, INPUT);
  pinMode(CLOCK_IN, INPUT);
  pinMode(CS, INPUT);

  for(int n = 0; n < 6; n++)
  {
    pinMode(ADDR[n], INPUT);  
  }

  resetDatabus();

  attachInterrupt(digitalPinToInterrupt(CLOCK_IN), readBuses, RISING);
  //attachInterrupt(digitalPinToInterrupt(CLOCK_IN), resetDatabus, FALLING);

  Serial.begin(115200);
  Serial.println("Alive!");
}

void loop() {
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

void readBuses(){
  if(digitalRead(CS) == HIGH) return;
  
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
