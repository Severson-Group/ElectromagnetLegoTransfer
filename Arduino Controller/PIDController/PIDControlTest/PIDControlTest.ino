#include <PID_v1.h>

// LED PIN for debug
#define LED_PIN 13

// A3 as KP Input
#define KP_IN 3

// A2 as KD Input
#define KD_IN 2

// A7 as input
#define PIN_INPUT 7

// Use PIN5 with a PWM frequency of 980Hz as output
#define PIN_OUTPUT 5 

// doubles here are actually single-precision
double Setpoint, Input, Output;
double consKp=120, consKi=1, consKd= 0.1;

int t = 0;

PID pid(&Input, &Output, &Setpoint, consKp, consKi, consKd, DIRECT);

void setup() {
  Serial.begin(9600);
  //initialize the variables we're linked to
  Input = analogRead(PIN_INPUT)*5/(float)1023;
  Setpoint = 2;
  pid.SetMode(AUTOMATIC);
}

void loop() {
  t++;
  
  Input = analogRead(PIN_INPUT)*5/(float)1023;

  consKp = analogRead(KP_IN)*5/(float)1023*25;

  consKd = analogRead(KD_IN)*5/(float)1023*17;

  // Manually Adjust PD gains and report at intervals
  if (t%10000 == 0){
    Serial.print("Kp = ");
    Serial.print(consKp);
    Serial.print("Kd = ");
    Serial.println(consKd); 
  }
  
  pid.SetTunings(consKp, consKi, consKd);
  pid.Compute();
  analogWrite(PIN_OUTPUT, 255-Output);
  analogWrite(LED_PIN, 255-Output);
  
}
