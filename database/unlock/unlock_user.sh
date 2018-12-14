#!/bin/bash
mytool="/usr/bin/mysql -umyadmin -pmysupp@xmcx -h192.168.2.6 -P3306"
while read line
do
    $mytool -N -e "update navi_db.navi_user_logininfo set loginerrs=0 where userid in (select userid from navi_db.navi_uid_map where mp = $line)"
done<phone.txt
