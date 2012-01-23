import serial

class BasePeggy(object):
    HEIGHT_IN_PIX = 25
    WIDTH_IN_PIX = 25

    def __init__(self, device='/dev/tty.usbserial-A60049W8', baud=28800):
        self.ser = serial.Serial(device, baud)

    def write(self, data):
        self.ser.write(data)

    def done(self):
        self.ser.close()
