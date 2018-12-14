#!/bin/bash
#navi_host="192.168.2.6"
#core_host="192.168.2.11"
#mng_host=""
cd `dirname $0`

database_name=$1
table_name=$2
output=$3
conf_file="../../db-server"
all_database=`awk '{print $NF}' $conf_file |tr '\n,' ' '`
db_tool="mysql -umyadmin -pmysupp@xmcx -P3306"
db_bak="mysqldump -umyadmin -pmysupp@xmcx -P3306"
find_database_name()
{
	local table=$1
	for database in $all_database
	do
		host=`grep "$database" $conf_file | sort -n -k3|awk '{print $3}'|tail -1`
		$db_tool -h$host -N -e "show tables from $database"|grep "${table}$" > /dev/null 2>&1
		if [ $? -eq 0 ];then
			echo "$database"
			break
		else
			continue
		fi
	done
}
if [ -z "$database_name" ];then
	database_name=`find_database_name $table_name`
fi
host=`grep "$database_name" $conf_file | sort -n -k3|awk '{print $3}'|tail -1`
#echo "database is $database_name"
#echo $host
#$db_tool -h$host -e "select * from ${database_name}.${table_name} where DAY_ID between '20120430' and '20120518';" > ${table_name}.txt
#$db_tool -h$host  -N -e "select * from ${database_name}.${table_name} ;" > ${table_name}.txt
#$db_tool -h$host -e "select * from ${database_name}.${table_name} where MONTH_ID = 201206;" > ${table_name}.txt
if [ -z $output ];then
    $db_tool -h$host -e "select * from ${database_name}.${table_name} ;" 
#> ${table_name}.txt
#    sz ${table_name}.txt
#    rm -f ${table_name}.txt
else
    $db_bak -h$host ${database_name} ${table_name}
#>${table_name}.sql
#    sz ${table_name}.sql
#    rm -f ${table_name}.sql
fi

#$db_tool -h$host -e "select userid,mp,domain,eid,vgopprovince,vgopcity,orderflag,dmlflag,provincecode from ${database_name}.${table_name} where domain = 'ims.bj.chinamobile.com';" > ${table_name}.txt
#$db_tool -h$host -e "select * from ${database_name}.${table_name} where create_date > '2012-05-31 23:59:59';" > ${table_name}.txt
#$db_tool -h$host  ${database_name} ${table_name} > ${table_name}.txt
