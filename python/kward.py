#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
def test(*arg,**kwargs):  
    print arg   
    print kwargs  
    print "-------------------"   
    if a:
        print a
  
if __name__=='__main__':  
    #test(1,2,3,4,5)  
    test(a=1,b=2,c=3)  
    #test(1,2,3,a=1,b=3,c=5)  
