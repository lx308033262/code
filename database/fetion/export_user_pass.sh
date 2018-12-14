#!/bin/bash
eid=$1
mytool='/EUT/db/mysql7000/bin/mysql -uroot -psecret -S /EUT/db/mysql7000/mysql.sock'
$mytool -N -e "select mp,fetionpwd,imspwd,ppasswd from navi_db.navi_uid_map where eid = ${eid}" > /tmp/${eid}_user.txt
if [ $? -eq 0 ];then
    echo "200"
fi
