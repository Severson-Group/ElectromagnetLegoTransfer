void setup() {
  // put your setup code here, to run once:
  pinMode(12,OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(12, HIGH);
  delayMicroseconds(500); // Approximately 10% duty cycle @ 1KHz
  digitalWrite(12, LOW);
  delayMicroseconds(1000 - 500);
}
