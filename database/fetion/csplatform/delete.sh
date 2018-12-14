#!/bin/bash
mytool='mysql -umyadmin -pmysupp@xmcx -h 192.168.2.21 -P3306'
sql="delete from ics_db.ics_indict where corpcode != 110;"
$mytool -N -e "$sql"
