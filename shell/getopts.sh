#!/bin/bash
while getopts abcdefgh: arg
do
    case $arg in
    a) echo a;exit;;
    b) echo b;exit;;
    c) echo c;exit;;
    d) echo d;exit;;
    e) echo e;exit;;
    f) echo f;exit;;
    g) echo g;exit;;
    h) echo ${OPTARG}a ${OPTIND}a ${ARGS}a;exit;;
  esac
done
