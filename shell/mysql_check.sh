#!/bin/bash

# Script Name: mysql_status_check.sh
# Description: check mysql servers status
# Author: Xinggang Wang - OpsEye.com
# Create Date: 2012/3/30

#获取MySQL所在服务器IP/端口/用户名/密码
read -p "Host=" HOST
read -p "Port=" PORT
read -p "User=" USER
read -sp "Password=" PASSWORD
echo

#默认为127.0.0.1/3306/root
if [ "${HOST}" = "" ]
then
HOST='127.0.0.1'
fi

if [ "${PORT}" = "" ]
then
PORT='3306'
fi

if [ "${USER}" = "" ]
then
USER='root'
fi

#注意密码为空的时候的格式
mysql_list="
$HOST:$PORT:$USER:$PASSWORD
"
#计算函数，提高脚本效率
compute(){
 formula="$1"
 awk 'BEGIN{printf("%.2f",'$formula')}' 2>/dev/null &&
 echo $value || echo NULL
}

for mysql in $mysql_list
{
 host=${mysql%%:*}
 port=$(echo $mysql|awk -F: '{print $2}')
 user=$(echo $mysql|awk -F: '{print $3}')
 passwd=${mysql##*:}

 [ -z "$passwd" ] && mysql="mysql -h$host -P$port -u$user" ||
 mysql="mysql -h$host -P$port -u$user -p$passwd"

 unset Uptime
 # 把show global status的值赋给相应的参数名称（这里相当于大量的变量赋值操作）
 eval $( $mysql -e "show global status" | awk '{print $1"=\x27"$2"\047"}')
 [ X = X"$Uptime" ] && continue

 # Mysql VER
 VER=`$mysql -e"status;"|grep 'Server version'|awk '{print $3}'`

 # Uptime
 UPTIME=`compute "$Uptime/3600/24"`

 # Threads_connected
 threads_connected=`compute "$Threads_connected"`

 # QPS Questions/Uptime
 qps=`compute "$Questions/$Uptime"`

 # TPS (Com_commit + Com_rollback)/Uptime
 tps=`compute "($Com_commit+$Com_rollback)/$Uptime"`

 # Reads Com_select + Qcache_hits
 reads=`compute "$Com_select+$Qcache_hits"`

 # Writes Com_insert + Com_update + Com_delete + Com_replace
 writes=`compute "$Com_insert+$Com_update+$Com_delete+$Com_replace"`

 # Read/Writes Ratio reads/writes*100%
 rwratio=`compute "$reads/$writes*100"`%

 # MyISAM Key_buffer_read_hits (1 - Key_reads/Key_read_requests) * 100
 key_buffer_read_hits=`compute "(1-$Key_reads/$Key_read_requests)*100"`%

 # MyISAM Key_buffer_write_hits (1 - Key_writes/Key_write_requests) * 100
 key_buffer_write_hits=`compute "(1-$Key_writes/$Key_write_requests)*100"`%

 # Query_cache_hits (Qcache_hits / (Qcache_hits + Qcache_inserts)) * 100%
 query_cache_hits=`compute "$Qcache_hits/($Qcache_hits+$Qcache_inserts)*100"`%

 # Innodb_buffer_read_hits (1 - Innodb_buffer_pool_reads/Innodb_buffer_pool_read_requests) * 100
 innodb_buffer_read_hits=`compute "(1-$Innodb_buffer_pool_reads/$Innodb_buffer_pool_read_requests)*100"`%

 # Thread_cache_hits (1 - Threads_created / Connections) * 100%
 thread_cache_hits=`compute "(1-$Threads_created/$Connections)*100"`%

 # Slow_queries_per_second Slow_queries / Uptime * 60
 slow_queries_per_second=`compute "$Slow_queries/$Uptime*60"`

 # Select_full_join_per_second Select_full_join / Uptime * 60
 select_full_join_per_second=`compute "$Select_full_join/$Uptime*60"`

 # select_full_join_in_all_select (Select_full_join / Com_select) * 100
 select_full_join_in_all_select=`compute "($Select_full_join/$Com_select)*100"`%

 # MyISAM Lock Contention (Table_locks_waited / Table_locks_immediate) * 100
 myisam_lock_contention=`compute "($Table_locks_waited/$Table_locks_immediate)*100"`%

 # Temp_tables_to_disk (Created_tmp_disk_tables / Created_tmp_tables) * 100
 temp_tables_to_disk_ratio=`compute "($Created_tmp_disk_tables/$Created_tmp_tables)*100"`%

 # print formated MySQL status report
 title="******************** MySQL--${HOST}--${PORT} ***********************"
 width=$((`echo "$title"|wc -c`-1))

 echo "$title"

 export IFS=':'
 while read name value ;do
 printf "%36s :\t%10s\n" $name $value
 done <<EOF
Mysql Ver:$VER
Uptime:$UPTIME days
Threads connected:$threads_connected
QPS:$qps
TPS:$tps
Reads:$reads
Writes:$writes
Read/Writes Ratio:$rwratio
MyISAM Key buffer read hits(>99%):$key_buffer_read_hits
MyISAM Key buffer write hits:$key_buffer_write_hits
Query cache hits:$query_cache_hits
InnoDB buffer read hits(>95%):$innodb_buffer_read_hits
Thread cache hits(>90%):$thread_cache_hits
Slow queries per second:$slow_queries_per_second
Select full join per second:$select_full_join_per_second
Select full join in all select:$select_full_join_in_all_select
MyiSAM lock contention(<1%):$myisam_lock_contention
Temp tables to disk ratio:$temp_tables_to_disk_ratio
EOF

 unset IFS

 for i in `seq $width`;{ echo -n "*";};echo
}

exit 0
