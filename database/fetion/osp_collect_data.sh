#!/bin/bash
mytool='mysql -S /EUT/db/mysql7000/mysql.sock  -uroot -psecret -N navi_db'
start_date='20131001'
for ((i=1;i<120;i++))
do 
    day=`$mytool -e "select date_format(adddate('${start_date}',$i),'%Y%m%d');"`
    $mytool -e "call UP_RPT_CLIENT_LOGIN(${day})"
done
