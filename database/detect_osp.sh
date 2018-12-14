#!/bin/bash
mysql-EUT='/EUT/db/mysql7000/bin/mysql -uroot -psecret -S /EUT/db/mysql7000/mysql.sock'
eid=100038
for tb in `mysql-EUT -N  -D navi_db -e "show tables like 'navi_client_oper%'"`
do 
    echo $tb
    mysql-EUT -N -e "select a.userid,b.eid from navi_db.$tb a left join cinf_db.cinf_employees b on a.userid = b.userid where b.eid = $eid "
done
