#!/bin/bash
#外侧
#db_tool="mysql -umyadmin -punknown -P8400 -h192.168.0.136"
#上地
host=""
db_tool="mysql -umyadmin -pmysupp@xmcx -h${host}"
database_name=""
sql="alter table ${database_name}.${line} add column abc int(11);"
$db_tool -N -e "show tables from ${database_name} like 'bac%';" > table.name
while read line
do
    $db_tool -e $sql
done
