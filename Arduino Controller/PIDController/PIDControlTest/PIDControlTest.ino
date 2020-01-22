#include "PID_v1.h" 

// LED PIN for debug
#define LED_PIN 13

// A4 as KP Input
#define KP_IN 4

// A3 as KD Input
#define KD_IN 3

// A2 as KI Input
#define KI_IN 2

// A1 as SP Input
#define SP_IN 1

// A7 as input
#define PIN_INPUT 7

// Use PIN5 with a PWM frequency of 980Hz as output
#define PIN_OUTPUT 5 

// doubles here are actually single-precision
double Setpoint, Input, Output;
double consKp=120, consKi=0, consKd= 15;

int t = 0;
int pid_t = 0;
int pid_t_last = 0;

PID pid(&Input, &Output, &Setpoint, consKp, consKi, consKd, REVERSE);

unsigned long lastLoopTime  ;

void setup() {
  Serial.begin(9600);
  //initialize the variables we're linked to
  Input = analogRead(PIN_INPUT)*5/(float)1023;
  Setpoint = 1.0;
  pid.SetOutputLimits(0, 255);
  pid.SetMode(AUTOMATIC);
  lastLoopTime = micros(); 
}

// Max input voltage for hand controls is 4.74

void loop() {
  t++;
  
  Input = analogRead(PIN_INPUT)*5/(float)1023;
// Correct Input for electromagnet input (fudge factor)
// Could do this automatically on start-up with no magnet in the middle 
//  Input = Input + (-0.20)*((Output)/255)+0.20;

  consKp = analogRead(KP_IN)/(float)1023*250;
  consKi = analogRead(KI_IN)/(float)1023*100;
  consKd = analogRead(KD_IN)/(float)1023*10;

  Setpoint = analogRead(SP_IN)/(float)1023*3.5;

  // Manually Adjust PD gains and report at intervals
 
  if (t%10000 == 0){
    unsigned long now = micros();
    unsigned long timeChange = (now - lastLoopTime);
    unsigned int pid_change = (pid_t - pid_t_last);
    Serial.print("Kp = ");
    Serial.print(consKp);
    Serial.print(" Kd = ");
    Serial.print(consKd); 
    Serial.print(" Ki = ");
    Serial.print(consKi); 
    Serial.print(" Input = ");
    Serial.print(Input); 
    Serial.print(" Output = ");
    Serial.print(Output); 
    Serial.print(" Setpoint = ");
    Serial.print(Setpoint); 
    Serial.print(" Loop per second = ");
    Serial.print(10000*1000000/timeChange); 
    Serial.print(" PID per second = ");
    Serial.println(pid_change*1000000/timeChange); 
    pid_t_last = pid_t;
    lastLoopTime = now;
  }
  
  
  pid.SetTunings(consKp, consKi, consKd);
  if(pid.Compute()) {
    pid_t++;
  }
  analogWrite(PIN_OUTPUT, Output);
}
