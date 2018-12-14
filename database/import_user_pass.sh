#!/bin/bash
eid=$1
mytool='/EUT/db/mysql7000/bin/mysql -uroot -psecret -S /EUT/db/mysql7000/mysql.sock'
file=/tmp/${eid}_user.txt
day=`date +%F`
[ ! -f $file ] && echo "can't find user.txt,exit" && exit 1
while read mp fetionpwd imspwd ppasswd
do
        $mytool -N -e "update navi_db.navi_uid_map set fetionpwd = '$fetionpwd',imspwd = '$imspwd',ppasswd = '$ppasswd' where mp = $mp"
done<$file
if [ $? -eq 0 ];then
        echo "200"
fi
mv $file ${file}-${day}
