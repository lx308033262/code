#!/bin/bash
while :
do
    read var < /tmp/pipe
    echo "from pipe file variables is $var"
    sleep 0.5
done
