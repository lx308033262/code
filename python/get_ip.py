#!/usr/bin/python
# -*- coding: utf-8 -*-
 

import re
from subprocess import PIPE,Popen
print re.search('\d+\.\d+\.\d+\.\d+',Popen('ifconfig', stdout=PIPE).stdout.read()).group(0)
