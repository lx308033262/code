#!/usr/bin/env python
# -*- coding: utf-8 -*-

import re,ConfigParser,glob
expr_file="expr.ini"
files=glob.glob("*.log")

cf=ConfigParser.ConfigParser()
cf.read(expr_file)

type_name="switch"
#for opt in cf.options("switch"):
for filename in files:
    ip=filename.rstrip(".log")
    print '==============',ip, '==============='
    if cf.has_section(ip):
        sec_name=ip
    elif ip == "172.16.4.135":
        sec_name="inner_fw"
    else:
        sec_name=type_name
    for opt in cf.options(sec_name):
        print '=============', opt, '=============='
        expr_list=eval(cf.get("switch",opt))
        for expr in expr_list:
            com=re.compile(expr)
            for line in open(filename):
                if com.search(line):
                    print line

