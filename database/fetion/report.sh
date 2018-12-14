#!/bin/bash
my='/usr/local/mysql/bin/mysql -uroot -psecret -S /tmp/mysql.sock -D 'navi_db''
today=`date +%Y%m%d`
#today=`date -d '1 days ago' +%Y%m%d`

$my -N -e "drop table if exists login_count_$today;"
$my -e "create table if not exists login_count_$today(eid int,corpname varchar(256),mp bigint(20),userid bigint(20),login_count int(11),from_table varchar(50) default 'n');"
for table in `$my -N -e "show tables like 'navi_client_oper_history%'"|sed -n '1,/'$today'/p'`
do
    
    $my -N -e "insert into login_count_$today(mp,userid,login_count) select a.mp,b.userid,count(*) from navi_uid_map a,$table b where b.actioncode=99 and a.userid = b.userid group by b.userid;"
    $my -N -e "update login_count_$today set from_table = '$table' where from_table = 'n';"
done
$my -N -e "update login_count_$today t1 left join cinf_db.cinf_employees t2 on t1.userid = t2.userid set t1.eid = t2.eid;"
$my -N -e "update login_count_$today t1 left join cinf_db.cinf_corporations t2 on t1.eid = t2.eid set t1.corpname = t2.corpname;"
#$my -N -e "select mp,sum(login_count) from login_count_$today group by mp"
$my  -e "select eid,count(distinct mp) as count_person,sum(login_count) as sum_login_count,corpname from login_count_$today group by eid with rollup"
