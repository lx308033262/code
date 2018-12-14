#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
from optparse import OptionParser
parser = OptionParser(add_help_option=0)
parser.add_option("-A", "--auto", action="store_true",dest="auto",default=False)

(options, args) = parser.parse_args()

print options.auto
