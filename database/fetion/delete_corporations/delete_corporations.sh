#!/bin/bash
#mytool="mysql -umyadmin -punknown"
#myport="8400"
#myip="192.168.0.136"
myport=3306
mytool="mysql -umyadmin -pmysupp@xmcx"
myback="mysqldump -umyadmin -pmysupp@xmcx"
qyid=$1

myip="192.168.2.6"
sql="select userid from navi_db.navi_uid_map where eid=$qyid;"
uids=`$mytool -P$myport -h$myip -N -e "$sql"|tr '\n' ','|sed 's/,$//'`
#if [ -z "$uids" ];then
#	echo "wrong corporations"
#	exit
#fi

myip="192.168.2.11"
sql="delete from  cinf_db.cinf_corporations where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_corporations -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_departments where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_departments -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_sys_switch where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_sys_switch -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_thresholds where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_thresholds -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_employees where  eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_employees -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_roles where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_roles -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_role_right_map where  eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c cinf_db cinf_role_right_map -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_grp_users where grpid in (select grpid from cinf_db.cinf_groups where eid=$qyid);"
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from cinf_db.cinf_groups where  eid=$qyid;"
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from osp.osp_systemnote where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c osp osp_systemnote -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

for i in ` seq -f  "%02g" 9`
do
    sql="delete from osp.osp_systemnote_${i} where eid=$qyid;"
    $mytool -P$myport -h$myip -N -e "$sql"
done

sql="delete from osp.osp_msg_system where eid=$qyid;"
$mytool -P$myport -h$myip -N -e "$sql"

for i in ` seq -f  "%02g" 9`
do
    sql="delete from osp.osp_msg_system_${i} where eid=$qyid;"
    $mytool -P$myport -h$myip -N -e "$sql"
done

sql="delete from imop_db.imop_admin_permission where adminid in(select adminid from imop_db.imop_admin where eid=$qyid);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c imop_db imop_admin_permission -w "adminid in(select adminid from imop_db.imop_admin where eid=$qyid)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from imop_db.imop_admin where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c imop_db imop_admin -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from imop_db.imop_admin_dept where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c imop_db imop_admin_dept -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from ubiz_db.ubiz_reminders_users where rmnduid in ($uids);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c ubiz_db ubiz_reminders_users -w "rmnduid in ($uids)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from ubiz_db.ubiz_weathers where userid in ($uids);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c ubiz_db ubiz_weathers -w "userid in ($uids)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from ubiz_db.ubiz_capability_map where userid in ($uids);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c ubiz_db ubiz_capability_map -w "userid in ($uids)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

myip="192.168.2.6"
sql="delete from navi_db.navi_eid_map where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c navi_db navi_eid_map -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from navi_db.navi_mp_map where userid in($uids);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c navi_db navi_mp_map -w "userid in($uids)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

#delete from navi_db.navi_mp_map a,navi_db.navi_uid_map b, where a.userid=b.userid and eid=$qyid;
sql="delete from navi_db.navi_uri_map where userid in ($uids);"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c navi_db navi_uri_map -w "userid in ($uids)" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"

sql="delete from navi_db.navi_uid_map where eid=$qyid;"
#$myback -P$myport -h$myip --single-transaction --no-create-info -c navi_db navi_uid_map -w "eid=$qyid" >> bak_corporations.sql
$mytool -P$myport -h$myip -N -e "$sql"
