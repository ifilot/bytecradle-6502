void setup() {
  // Initialize Serial (USB connection to computer)
  Serial.begin(19200);

  // Initialize Serial1 (Hardware serial for incoming data)
  Serial1.begin(19200); // Match the baud rate of your ACIA
}

void loop() {
  // Forward data from Serial1 to Serial
  if (Serial1.available()) {
    char incomingByte = Serial1.read();
    Serial.write(incomingByte); // Send the byte to the computer
  }

  // Optionally, forward data from Serial to Serial1 (e.g., to send commands)
  if (Serial.available()) {
    char outgoingByte = Serial.read();
    Serial1.write(outgoingByte); // Send the byte to the ACIA or other device
  }
}
