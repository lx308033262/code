#!/bin/bash
[ -p "/tmp/pipe" ] || mkfifo /tmp/pipe
fun(){
    all=$*
    for i in $all
    do
        set -m
        echo $i > /tmp/pipe &
        wait
        set +m
    done
}
fun a b c d e f g
echo > /tmp/pipe
