#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os,sys

import MySQLdb

import getpass



#host=raw_input("host:")
#user=raw_input("user:")
#password=getpass.getpass()
host='192.168.199.17'
user='root'
password='secret'
port=7000



try:

   conn = MySQLdb.connect(host = host, user=user ,passwd = password, port = port,db = 'test')

except MySQLdb.Error,e:

   print "Error %d:%s"%(e.args[0],e.args[1])

   exit(1)

cursor=conn.cursor()



cursor.execute('show global status;')

result_set=cursor.fetchall()

cursor.close()

conn.close()



def get_value(key_name):
    for rows in result_set:
        if rows[0]==key_name:
            return float(rows[1])



print ('MySQL-'+host+"-"+str(port)).center(60,'*')

print 'Uptime:'.rjust(40),get_value('Uptime')

print 'Threads_connected:'.rjust(40),get_value('Threads_connected')

print 'QPS:'.rjust(40),round(get_value('Questions') / get_value('Uptime'),2)

print 'TPS:'.rjust(40),round((get_value('Com_commit')+get_value('Com_rollback'))/ get_value('Uptime'),2)

reads=get_value('Com_select')+ get_value('Qcache_hits')

writes=get_value('Com_insert')+get_value('Com_update')+get_value('Com_delete')+get_value('Com_replace')

print 'Reads:'.rjust(40),get_value('Com_select')+ get_value('Qcache_hits')

print 'Writes:'.rjust(40),get_value('Com_insert')+get_value('Com_update')+get_value('Com_delete')+get_value('Com_replace')

print 'Read/Writes Ratio:'.rjust(40),round(reads / writes,2),'%'

print 'MyISAM Key buffer read hits(>99%):'.rjust(40),round(1-get_value('Key_reads') / (get_value('Key_read_requests')),5)*100,'%'

print 'MyISAM Key buffer write hits:'.rjust(40),round(1-get_value('Key_writes') / (get_value('Key_write_requests')),5)*100,'%'

if int(get_value('Qcache_hits')) !=0:
    print 'Query cache hits:'.rjust(40),round(get_value('Qcache_hits') / (get_value('Qcache_hits')+get_value('Qcache_inserts')),5) * 100,'%'

print 'InnoDB buffer read hits(>95%):'.rjust(40),round((1-get_value('Innodb_buffer_pool_reads') / get_value('Innodb_buffer_pool_read_requests')),5)* 100,'%'

print 'Thread cache hits(>90%):'.rjust(40),round(1-get_value('Threads_created') / (get_value('Connections')),5)*100,'%'

print 'Slow queries per second:'.rjust(40),round(get_value('Slow_queries') / get_value('Uptime'),2)

print 'Select full join per second:'.rjust(40),round(get_value('Select_full_join') / get_value('Uptime'),2)

print 'Select full join in all select:'.rjust(40),round(get_value('Select_full_join') / (get_value('Com_select')),5)*100,'%'

print 'MyISAM lock contention(<1%):'.rjust(40),round(get_value('Table_locks_waited') / (get_value('Table_locks_immediate')),5)*100,'%'

print 'Temp tables to disk ratio:'.rjust(40),round(get_value('Created_tmp_disk_tables') / (get_value('Created_tmp_tables')),5)*100,'%'

print '*'*60
