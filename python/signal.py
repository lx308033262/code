#!/usr/bin/env python
# -*- coding: utf-8 -*-
 

import signal
import time
import sys

#定义遇到信号的处理
def handler(signo, frame):
    print "got signal", signo
    sys.exit()


#定义获取到ctrl +c 信号，进行handler处理
signal.signal(signal.SIGINT, handler)

#定义获取到ctrl +d 信号，进行handler处理
signal.signal(signal.SIGTSTP, handler)

#定义获取到alrm信号，进行handler处理
signal.signal(signal.SIGALRM, handler)

# 强制在2秒后发出alrm信号
#signal.alarm(2)  

#now = time.time()

#time.sleep(200)   

#print "slept for", time.time() - now, "seconds"

#while True:
#try:
#    time.sleep(200)
#except KeyboardInterrupt:
#    print "got ctrl + c,exit"
time.sleep(200)


