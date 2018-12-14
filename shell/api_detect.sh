#!/bin/bash

url=$1
host=$2
keyword=$3
file=/tmp/${host}.txt
#curl  -H "host:buaa.gaoxiaobang.com"   -s -w "\n%{http_code}\n"%{time_total}"\n"  $url &> $file
curl  -s -w "\n%{http_code}\n"%{time_total}"\n"  $url &> $file
http_code=`tail -n2 $file|head -1`
if [ "$http_code" != "200" ];then
    echo 1
    exit
fi
#sed -i '/'$host'/d' /etc/hosts
#if [[ "$host" =~ "cms-api" ]];then
    #grep "success" $file > /dev/null 2>&1
#else
    grep "$keyword" $file > /dev/null 2>&1
#fi
echo $?
