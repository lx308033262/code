#!/bin/bash
iplst="192.168.2.11"
db_tool="mysql -umyadmin -pmysupp@xmcx -P3306 -h$iplst"
db_bak="mysqldump -umyadmin -pmysupp@xmcx -P3306 -h$iplst"
#测试
#db_tool="mysql"
#db_bak="mysqldump"
day=`date +%F`
#mps=''
mps='03512982001,03512982002,03512982003,03512982004,03512982005,03512973001,03512973002,03512973003,03512973004,03512973005'

############################ update version ############################################
#	 tmp=`date +%s`							    	
#	 sqlstr="update cinf_db.cinf_corporations set corgversion=$tmp      
#	 where eid in ($eids); "					    
#	 $db_tool -N -e "$sqlstr"				            
#	 echo "update successfully"  					    


############################# get userid ###########################################
sql="select userid from cinf_db.cinf_employees where mp in ($mps);"
uids=`$db_tool -N -e "$sql"`
if [ -z "$uids" ];then
    echo -e "$sql;\nresult is NULL"
    exit
else
    uid=`echo -e "$uids"|tr '\n' ','|sed 's/,$//'`
fi

###########################	get eid ################################################
sql="select eid from cinf_db.cinf_employees where mp in ($mps);"
eids=`$db_tool -N -e "$sql"`
if [ -z "$eids" ];then
    echo -e "$sql;\nresult is NULL"
    exit
else 
    echo "true"
fi
echo "-- $mps" > delete_employees_cinf_db-${day}.sql
echo "-- $uid" > delete_employees_cinf_db-${day}.sql

###################################### WEB Delete tables ############################################################
sqlstr="delete from cinf_db.cinf_employees where userid in ($uid);"
$db_bak --no-create-info -c cinf_db cinf_employees -w "userid in ($uid)" >> delete_employees_cinf_db-${day}.sql
$db_tool -N -e "$sqlstr"
yanzheng=`$db_tool -N -e "$sqlstr"`
if [ -z "$yanzheng" ];then
    echo "delete successfully"
else
    echo "delete failed"       
fi

sqlstr="delete from cinf_db.cinf_grp_users where userid in ($uid);"
$db_bak --no-create-info -c cinf_db cinf_grp_users -w "userid in ($uid)" >> delete_employees_cinf_db-${day}.sql
$db_tool -N -e "$sqlstr"
yanzheng=`$db_tool -N -e "$sqlstr"`
if [ -z  "$yanzheng" ];then
    echo "delete successfully"
else
    echo "delete failed"
fi
