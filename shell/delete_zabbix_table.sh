#!/bin/bash

mytool=''
expire_day=90
time_num=`date  +%s -d ''${expire_day}' days ago'`
for tb in history history_uint trends trends_uint events
do
    $mytool -N -e "DELETE FROM $tb where clock < $time_num;"
    $mytool -N -e "optimize table history;"
done
