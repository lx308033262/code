#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
import logging
#LOG=logging.ge
def test():
    """
    stupid test function
    """
    L = []
    for i in range(100):
        L.append(i)

if __name__ == '__main__':
    from timeit import Timer
    t = Timer("test()","from __main__ import test")
    print t.timeit(1000)
