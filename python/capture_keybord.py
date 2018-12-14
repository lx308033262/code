#!/usr/bin/env python
# -*- coding: utf-8 -*-

import termios, sys, os

f=open('t.log','a')
def getkey():
    term = open("/dev/tty", "r")
    fd = term.fileno()
    old = termios.tcgetattr(fd)
    new = termios.tcgetattr(fd)
    new[3] &= ~termios.ICANON & ~termios.ECHO
    termios.tcsetattr(fd, termios.TCSANOW, new)
    c = None
    try:
        c = os.read(fd, 1)
    finally:
        termios.tcsetattr(fd, termios.TCSAFLUSH, old)
        term.close()
    return c

if __name__ == '__main__':
    print 'type something'
    s = ''
    while 1:
        c = getkey()
        if c == 'n':
            break
        if c == "exit":
            sys.exit()
        print 'got', c
        s = s + c
    #print s
    f.write(s)
    f.close()
