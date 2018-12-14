#!/bin/bash

b=''

#for ((i=0;$i<=100;i+=2))
for ((i=0;$i<=100;i+=1))

do

    #printf "progress:    [%-50s]   %d%%\r" $b $i
    printf "progress:    [%-100s]   %d%%\r" $b $i

    sleep 0.1

    b=#$b

done

echo ''

