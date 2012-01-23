#!/usr/bin/env python
from pegpy import BasePeggy
import os
import time
import random
from pbm import pbm_lines


class FrameDisplayPeggy(BasePeggy):
    """Peggy interface that uses a simple protocol to write display
    data to a peggy board.
    """
    FRESH_FRAME = '^'
    ADDITIVE_FRAME = '+'
    SUBTRACTIVE_FRAME = '-'
    END_LINE = ';'
    WIDTH_IN_BYTES = 4
    BLANK_FRAME = ['\x00\x00\x00\x00' for _ in range(BasePeggy.HEIGHT_IN_PIX)]

    def _frame(self, lines, frame_type):
        self.write(frame_type)
        if not lines:
            lines = self.BLANK_FRAME
        for line in lines:
            self.write(line)
            self.write(self.END_LINE)

    def fresh_frame(self, lines=None):
        self._frame(lines, self.FRESH_FRAME)

    def subtractive_frame(self, lines=None):
        self._frame(lines, self.SUBTRACTIVE_FRAME)

    def additive_frame(self, lines=None):
        self._frame(lines, self.ADDITIVE_FRAME)

    def random_frame(self):
        frame = [''.join([chr(random.randint(0,255)) 
                    for x in range(self.WIDTH_IN_BYTES)])
                    for y in range(self.HEIGHT_IN_PIX)]
        self.fresh_frame(frame)

if __name__ == '__main__':
    peggy = FrameDisplayPeggy()
    try:
        while(True):
            img_dir = '../images/'
            for dirname, dirnames, filenames in os.walk(img_dir):
                random.shuffle(filenames)
                if not filenames[0].startswith('.'):
                    peggy.frame(pbm_lines(img_dir + filenames[0]))
            time.sleep(2)
    except Exception, e:
        print e
    finally:
        peggy.done()
