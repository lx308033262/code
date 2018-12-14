#!/bin/bash
my_bak="/usr/bin/mysqldump -umyadmin -pmysupp@xmcx -h 192.168.2.11 -P3306"
my_tool="/usr/bin/mysql -umyadmin -pmysupp@xmcx  -P3306 -h192.168.2.6"
$my_bak -n scfg_db scfg_ssikeys > navi_ssikeys.sql
sed -i 's/scfg_ssikeys/navi_ssikeys/g' navi_ssikeys.sql
$my_tool navi_db < navi_ssikeys.sql
