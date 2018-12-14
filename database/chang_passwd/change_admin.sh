#!/bin/bash

#外测
#host="192.168.0.136"
#db_tool="mysql -uroot -psecret -h$host -P8400"

#上地
host="192.168.2.11"
db_tool="mysql -umyadmin -pmysupp@xmcx -P3306 -h$host"
corpcode="35110000"
#eid="3050127"
user_name="admins"
passwd="aaa111"
#exec_str="update imop_db.imop_admin set md5pwd=md5('"$passwd"') where eid = '$eid' and adminname='$user_name';"
exec_str="update imop_db.imop_admin set md5pwd=md5('"$passwd"') where corpcode = '$corpcode' and adminname='$user_name';"
echo $exec_str
$db_tool -e "$exec_str"
