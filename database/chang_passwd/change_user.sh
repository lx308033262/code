#!/bin/bash
#gd123456	yxNI+qYrMRAyIp59uaJF7g==
#ims123456	KZ3pz9iEAq2e25uCrVWV9g==
#e123456	+fvnqGSx2tORhPmcFHSzHQ==
#123456 	9w5LkNoZCEFYNS2ZIEvYAw== 
#46281087

#外测
#host="192.168.0.136"
#db_tool="mysql -uroot -psecret -h$host -P8400"

#上地
host="192.168.2.6"
db_tool="mysql -umyadmin -pmysupp@xmcx -P3306 -h$host"
passwd="yxNI+qYrMRAyIp59uaJF7g=="
#passwd='GleCoHAE3Gdlq4yg9rZ9/w=='
while read line
do
	exec_str="update navi_db.navi_uid_map set fetionpwd='$passwd' where mp = $line;"
	$db_tool -e "$exec_str"
	query_str="select fetionpwd from navi_db.navi_uid_map where mp = $line and dmlflag <> 3;"
	result=`$db_tool -N -e "$query_str"`
	if [ "$result" == "$passwd" ];then
		echo "$line change password successful!"
		echo "echo $result"
	else
		echo "$line change password faild!!!"
		echo "echo $result"
	fi
done<phone.list
> phone.list
