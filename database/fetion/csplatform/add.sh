#!/bin/bash
S_FILE="./a.txt"
F_LINE=`wc -l $S_FILE|awk '{print $1}'`
day=`date '+%Y%m%d'`
mytool='mysql -umyadmin -pmysupp@xmcx -h 192.168.2.21 -P3306'

for i in `seq $F_LINE`
do
	submittime=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $1}'`
	subsname=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $2}'`
	title=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $3}'`
	handlingstaff=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $4}'`
	operatetime=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $5}'`
	content=`sed -n "${i}p" $S_FILE|awk -F'\t' '{print $6}'`
	sql="INSERT INTO ics_db.ics_indict VALUES ('${day}CSVC22001074${i}qy', ' ', 110, 'CONT20120322CSVC2203110155', '01', now(), '企业飞信业务测试', 'SR20111227CSVC2203110153',13626239342,'"${subsname}"', '220-拉萨', '04', '04', '13626239342', '10086', '01', '09', '47', '03', '220', '0145', now(), '104-天津','"${title}"','"${title}"','审核通过', '2', '102', NULL, NULL, NULL, 1, NULL, NULL, NULL, 0, now(), 3392, NULL, NULL, NULL, NULL, NULL, NULL,'"${submittime}"', now(), now());"
	$mytool -N -e "$sql"
	#sql="INSERT INTO ics_db.ics_details_${day:0:6} VALUES ('${day}123133${i}','fff','eeee',' ',' ',' ','${content}',' ','"${handlingstaff}"',' ',' ',' ',' ',' ','"${operatetime}"',' ');"
	#$mytool -N -e "$sql"
done
