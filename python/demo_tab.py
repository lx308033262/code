#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
#! /usr/bin/env python
import os
from lib.completer import *
#from lib.common import *

def input_loop():
    line = ''
    readline.parse_and_bind('tab: complete')
    readline.parse_and_bind('set editing-mode vi')
    while True:
        line = raw_input("PSOP-SEB (NDI's Family): ")
        if line == 'stop' or line == 'quit' or line == 'exit':
            break
        elif line not in key_words:
            print str(key_words)
        print 'input: %s' %line

if __name__=='__main__':
    key_words="baidu","google","hi","gtalk","beiju"
    readline.set_completer(Completer(key_words).complete)

    cur_dir = get_cur_py_dir()
    par_dir = get_par_dir(cur_dir)

    input_loop()

