#include <Peggy2.h>
#include <inttypes.h>
#include <Wire.h>
#include "SPI.h"

#define PEGGY_ADDRESS 1
#define HEIGHT 25
#define BYTE_WIDTH 4
#define END_LINE ';'
#define FRESH_FRAME '^'
#define ADDITIVE_FRAME '+'
#define SUBTRACTIVE_FRAME '-'

// globals so that they can be accessed by i2C ISRs
Peggy2 frame;
uint8_t y = 0;
uint8_t x_byte = 0;

typedef void (* writeFunction) (uint8_t);
writeFunction currentOp;

union {
  uint32_t row; 
  uint8_t rowBytes[4];
} rowFacade;

void setByte(uint8_t c) {
  rowFacade.row = frame.buffer[y];
  rowFacade.rowBytes[x_byte] = c;
  frame.buffer[y] = rowFacade.row;
}

void addByte(uint8_t c) {
  rowFacade.row = frame.buffer[y];
  rowFacade.rowBytes[x_byte] |= c;
  frame.buffer[y] = rowFacade.row;
}

void clearByte(uint8_t c) {
  rowFacade.row = frame.buffer[y];
  rowFacade.rowBytes[x_byte] &= ~c;
  frame.buffer[y] = rowFacade.row;
}

void setup() {
  // I 2 C   S E T U P
  //Specify an address to set up Peggy as an I2C slave
  Wire.begin(PEGGY_ADDRESS);
  // Register the receiveEvent function with the library.
  Wire.onReceive(receiveEvent);

  // set pull up resistors on 4, 5 on PORTC.
  // These pins handle I2C comms.
  PORTC |= (1 << PC4) | (1 << PC5);

  // Call the display's initiatiion routine:
  frame.HardwareInit();

  SPI.setBitOrder(LSBFIRST);
}

void loop() {
  while(true) {
    frame.RefreshAll(1);
    delay(1);
  }
}

void receiveEvent(int numBytes) {
  while (Wire.available())
  {
    char c = Wire.receive();
    switch(c) {
      case FRESH_FRAME:
        x_byte = 0; y = 0;
        currentOp = setByte;
        break;
      case ADDITIVE_FRAME:
        x_byte = 0; y = 0;
        currentOp = addByte;
        break;
      case SUBTRACTIVE_FRAME:
        x_byte = 0; y = 0;
        currentOp = clearByte;
        break;
      case END_LINE:
        x_byte = 0;
        if (y < HEIGHT)
          y++;
        break;
      default:
        if (x_byte < BYTE_WIDTH) {
          currentOp(c);
          x_byte++;
        }
    }
  }
}
