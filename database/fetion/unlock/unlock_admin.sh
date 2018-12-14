#!/bin/bash
mytool="/usr/bin/mysql -umyadmin -pmysupp@xmcx -h192.168.2.11 -P3306"
while read line
do
    $mytool -N -e "update imop_db.imop_admin set errlogincount = 0 where eid = \"$line\" and adminname = \"admins\";"
done<phone.txt
