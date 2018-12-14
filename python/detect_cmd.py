#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
import os
def check_command(cmd=""):
    exists_flag=0
    for cmdpath in os.environ['PATH'].split(':'):
        if os.path.isdir(cmdpath) and cmd in os.listdir(cmdpath):
            return True
            exists_flag=1
    if not exists_flag:
        return False
if check_command(cmd="mysql"):
    print "true"
else:
    print "false"
