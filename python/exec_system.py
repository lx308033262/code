#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
import subprocess,os
cmd="ls /tmp"
statu=subprocess.Popen(cmd,shell=True)
os.system('ls /tmp')
