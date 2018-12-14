#!/bin/bash
#navi_host="192.168.2.6"
#core_host="192.168.2.11"
#mng_host=""
#cd `dirname $0`

db_tool="mysql -umyadmin -pmysupp@xmcx -P3306 -h192.168.2.6"
#echo -e "userid\tmp\t\torderflag\teid" > a.txt
while read line
do
#	$db_tool -N -e "select userid,mp,orderflag,eid from navi_db.navi_uid_map where mp = \"$line\" and orderflag =1 " >> a.txt
	$db_tool -N -e "select mp,orderflag from navi_db.navi_uid_map where mp = \"$line\"" >> t.t
#done < phone.list
done<a.txt
