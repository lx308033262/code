#!/bin/bash
#上地
iplst="192.168.2.6"
db_tool="mysql -umyadmin -pmysupp@xmcx -P3306 -h$iplst"
db_bak="mysqldump -umyadmin -pmysupp@xmcx -P3306 -h$iplst"
#测试
#db_tool="mysql"
#db_bak="mysqldump"
day=`date +%F`
mps='03512982001,03512982002,03512982003,03512982004,03512982005,03512973001,03512973002,03512973003,03512973004,03512973005'

############################# get userid ###########################################
sql="select userid from navi_db.navi_uid_map where mp in ($mps);"
uids=`$db_tool -N -e "$sql"`
if [ -z "$uids" ];then
    echo -e "$sql;\nresult is NULL"
    exit
else
    uid=`echo -e "$uids"|tr '\n' ','|sed 's/,$//'`
fi

###########################	get eid ################################################
sql="select eid from navi_db.navi_uid_map where mp in ($mps);"
eids=`$db_tool -N -e "$sql"`
if [ -z "$eids" ];then
    echo -e "$sql;\nresult is NULL"
    exit
else 
    echo "got eid,continue"
fi
echo "-- $mps" > delete_employees_navi_db-${day}.sql
echo "-- $uid" >> delete_employees_navi_db-${day}.sql

###################################### WEB Delete tables ############################################################
sqlstr="delete from navi_db.navi_uid_map where userid in ($uid);"
$db_bak --no-create-info -c navi_db navi_uid_map -w "userid in ($uid)" >> delete_employees_navi_db-${day}.sql
$db_tool -N -e "$sqlstr"
yanzheng=`$db_tool -N -e "$sqlstr"`
if [ -z  "$yanzheng" ];then
    echo "delete succeessfully"
else
    echo "delete failed"	
fi

sqlstr="delete from navi_db.navi_uri_map where userid in ($uid);"
$db_bak --no-create-info -c navi_db navi_uri_map -w "userid in ($uid)" >> delete_employees_navi_db-${day}.sql
$db_tool -N -e "$sqlstr"
yanzheng=`$db_tool -N -e "$sqlstr"`
if [ -z  "$yanzheng"  ];then
    echo "delete successfully"  
else
    echo  "delete failed"
fi

sqlstr="delete from navi_db.navi_mp_map where userid in ($uid);"
$db_bak --no-create-info -c navi_db navi_mp_map -w "userid in ($uid)" >> delete_employees_navi_db-${day}.sql
$db_tool -N -e "$sqlstr"
yanzheng=`$db_tool -N -e "$sqlstr"`
if [ -z "$yanzheng" ];then
    echo "delete successfully"
else
    echo "delete failed"  
fi
