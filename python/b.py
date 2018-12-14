#!/usr/bin/env python
# -*- coding: utf-8 -*-
def maopao(list):
    for i in range(0, len(list)):
        for j in range(len(list) - 1, i - 1, -1):
            if list[j] < list[j-1]:
                temp = list[j]
                list[j] = list[j-1]
                list[j-1] = temp
#printResult(list)
def printResult(list):
    for i in range(0, len(list)):
        print list[i],
    print 

List = [9,1,7,3,8,2,6,4,0]
maopao(List)
print List
