volatile unsigned long lastMicros , pulseWidth;
volatile byte pin, lastState, changed;

void setup(){
  Serial.begin(115200);

  pin = 3;
 
  lastMicros = micros();
}

byte bitpos = 0;
byte bouncecount = 0;

unsigned long hipw, lopw = 0;
byte firsttime = 1;

void loop(){
  if(changed){
    /*
    Serial.print("lastMicros:");
    Serial.print(lastMicros);  
    Serial.println();
    
  
    Serial.print("pulseWidth:");
    Serial.println(pulseWidth);
    */
    
    if(pulseWidth > 20000){
      
      if(firsttime){
        firsttime=0;
      }else{
      
        if(lastState==HIGH){ // rising edge
          lopw = pulseWidth;
          
          if(hipw > 40000){
            Serial.print(1);
          }else{
            Serial.print(0);
          }        
  
          bitpos++;
          
          if(bitpos>31){
           Serial.println();
           bitpos = 0;
          }         
          
        }else{
          hipw = pulseWidth;
        }
      }
      
    }
        
    changed = 0;
  }
  
  byte state = !((PINE & (1<<5))==0);

  if( lastState != state ){
    bouncecount++;
  }
  
  if( lastState != state ){
    unsigned long now = micros();
    
    pulseWidth = now - lastMicros;
    
    lastState = state;
    lastMicros = now;
    
    changed = 1;
  }

}

