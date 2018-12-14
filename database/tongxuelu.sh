#!/bin/bash
mytool='/EUT/db/mysql7000/bin/mysql -uroot -psecret -S /EUT/db/mysql7000/mysql.sock'
half_time=`$mytool -N -e "select subdate(now(),interval 30 minute);"`

for eid in `$mytool -N -e "select distinct eid from cinf_db.cinf_corporations a,uinf_db.uinf_users b where b.dmltime between '$half_time' and now();"`
do
    $mytool -e "update cinf_db.cinf_corporations set corgversion = corgversion + 1 where eid = $eid;"
done

for eid in `$mytool -N -e "select distinct eid from cinf_db.cinf_employees where dmltime between '$half_time' and now();"`
do
    $mytool -e "update cinf_db.cinf_corporations set corgversion = corgversion + 1 where eid = '$eid';"
done
