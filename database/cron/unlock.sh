#!/bin/bash
mytool="/usr/bin/mysql -umyadmin -pmysupp@xmcx -h192.168.2.6 -P3306"
sqlstr="select loginerrs from navi_db.navi_user_logininfo where loginerrs!=0"
errorstr=`$mytool -N -e "$sqlstr"|tr '\n' ','|sed 's/,$//g'`
if [ -z "$errorstr" ];then
   exit
fi
echo `date +%F`
$mytool -N -e "select userid from navi_db.navi_user_logininfo where loginerrs in ($errorstr);"
$mytool -N -e "update navi_db.navi_user_logininfo set loginerrs=0 where loginerrs in ($errorstr);"
