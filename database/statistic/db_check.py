#!/usr/bin/python
# -*- coding: utf-8 -*-


#大字典包括所有主机 每个主机为一个字典
#主机字典中包括一个所有库大小的字典sum和一个包括所有数据库名称的字典db
#db下每一个数据库为一个字典,字典名称为$database
#database字典中包括以下字典
#tb 所有表名 tb_n 所有表的数量 
#p_tb_n 全部分表数量 p_tb_uniq_n 有几个独立分表
#p_tb_name 所有分表的名称 p_tb_uniq_name 每个独立分表的前缀名(分表后缀一样只取一个表) 
#d_tb_n 所有日表数量 d_tb_uniq_n 所有独立日表数量 
#d_tb_name 所有日表名称 d_tb_uniq_name 所有日表名称(日期后缀一样只取一个表)
#m_tb_n 所有月表数量 m_tb_uniq_n 所有独立月表数量 
#m_tb_n 所有月表相关字典同日表 m_tb_uniq_name 所有月表名称(日期后缀一样只取一个表)


import MySQLdb,sys
import ConfigParser
import re



#write error log to err.log file
#sys.stderr=open("./err.log","a")
#sys.stderr=open("/dev/null","a")
cf=ConfigParser.ConfigParser()
cf.read("config.ini")
dictionary={}

for host in cf.sections():
    #print "-------------------",host,"-----------------------------"
    dictionary[host]={}
    dictionary[host]['ip']=cf.get(host,"ip")
    dictionary[host]['port']=int(cf.get(host,"port"))
    conn=MySQLdb.connect(host=cf.get(host,"ip"),port=int(cf.get(host,"port")),user="myadmin",passwd="mysupp@xmcx")
    cursor=conn.cursor()
    #给大字典中添加主机所有数据库大小的小字典
    cursor.execute("select concat(round(sum(DATA_LENGTH/1024/1024),2),'MB') as data  from information_schema.TABLES")
    dictionary[host]['sum']=cursor.fetchone()[0]
    dictionary[host]['db']={}
    for database in eval(cf.get(host,"databases")):
        dictionary[host]['db'][database]={}
        #print "db_name: ",database
        n=cursor.execute("show tables from %s" % database)
        #get all table name 
        dictionary[host]['db'][database]['tb']=[a[0] for a in cursor.fetchall()]
        #get table number
        dictionary[host]['db'][database]['tb_n']=n
        #get partion table number
        expr=re.compile(".*_0[0-9]$")
        part_list=[t for t in dictionary[host]['db'][database]['tb'] if expr.match(t)]
        if len(part_list) % 10 == 0:
            #print part_list
            dictionary[host]['db'][database]['p_tb_n']=len(part_list)
            dictionary[host]['db'][database]['p_tb_uniq_n']=len(part_list)/10
            dictionary[host]['db'][database]['p_tb_name']=part_list
            dictionary[host]['db'][database]['p_tb_uniq_name']=list(set([ i[0:-2] for i in part_list ]))
        #get monthly table number
        expr=re.compile(".*_[0-9]{6}$")
        month_list=[t for t in dictionary[host]['db'][database]['tb'] if expr.match(t)]
        dictionary[host]['db'][database]['m_tb_n']=len(month_list)
        dictionary[host]['db'][database]['m_tb_uniq_n']=len(list(set([ i[0:-6] for i in month_list ])))
        dictionary[host]['db'][database]['m_tb_name']=month_list
        dictionary[host]['db'][database]['m_tb_uniq_name']=list(set([ i[0:-6] for i in month_list ]))
        #get daily table number
        expr=re.compile(".*_[0-9]{8}$")
        daily_list=[t for t in dictionary[host]['db'][database]['tb'] if expr.match(t)]
        dictionary[host]['db'][database]['d_tb_n']=len(daily_list)
        dictionary[host]['db'][database]['d_tb_uniq_n']=len(list(set([ i[0:-8] for i in daily_list ])))
        dictionary[host]['db'][database]['d_tb_name']=daily_list
        dictionary[host]['db'][database]['d_tb_uniq_name']=list(set([ i[0:-8] for i in daily_list ]))
        #print dictionary[host]['db'][database]['tb']
        #print database,dictionary[host]['db'][database]['tb_n']
    cursor.close() 
    conn.close() 


#打印各种表的统计信息
def get_all_tb_info():
    for h in dictionary.keys():
        for d in dictionary[h]['db']:
            print "====================",d,"=========================="
            for k in dictionary[h]['db'][d].keys():
                #不打印所有表 和分区表、日表、月表的名称 
                if k != "tb" and k != "p_tb_name" and k != "m_tb_name" and k != "d_tb_name":
                    #如果这个统计项目，如分表数量，独立日表名称列表不为0才打印
                    if dictionary[h]['db'][d][k] and dictionary[h]['db'][d][k] != 0:
                        print k,dictionary[h]['db'][d][k]

#查看所有从库复制状态
def get_slave_stat():
    for s in dictionary.keys():
        if s.split('-')[1] == "slave":
            conn=MySQLdb.connect(host=cf.get(s,"ip"),port=int(cf.get(s,"port")),user="myadmin",passwd="mysupp@xmcx")
            cursor=conn.cursor()
            cursor.execute("show slave status")
            result=tuple(cursor.fetchall()[0])
            if result[10] != "Yes":
                print "Slave_IO_Running ",result[11]
            elif result[11] != "Yes":
                print "Slave_SQL_Running: ",result[12]
            elif result[-6] != 0:
                print "Seconds_Behind_Master: ",result[-6]
            elif result[6]-result[-17] != 0:
                print "slave behind master postion: ",result[6]-result[-17]
            else:
                #print s,"slave status ok"
                pass
            #print "-----------------"


#对所有主机进行循环 找出 master机器(s为master机器，d为slave机器)
#获取所有主从同步状态 通过表数对比
def get_rep_stat():
    for s in dictionary.keys():
        if s.split('-')[1] == "master":
            #截取主机前缀 用来查找slave
            ke=s.split('-')[0]
            #查找slave主机
            for d in dictionary.keys():
                if d.split('-')[0] == ke and d.split('-')[1] != "master":
                    #print s,d
                    #对主机下的所有数据库做循环
                    for db in dictionary[s]['db'].keys():
                        #print db
                        #对比master和slave的表数是否一样
                        if dictionary[s]['db'][db]['tb_n'] == dictionary[d]['db'][db]['tb_n']:
                            #print "ok",dictionary[s]['db'][db],dictionary[d]['db'][db]
                            #print "table number is equal",s,db,d,db
                            pass
                        else:
                            #如果不一样,分别创建一个对应master和一个slave所有表的列表
                            #print "no",s,db,d,db
                            #print "no",dictionary[s]['db'][db],dictionary[d]['db'][db]
                            #对列表做循环，消除两个表中都有的元素,打印主从中间不一样的表
                            src_table_name_list=dictionary[s]['db'][db]['tb']
                            dst_table_name_list=dictionary[d]['db'][db]['tb']
                            sl=src_table_name_list[0:]
                            dl=dst_table_name_list[0:]
                            #print src_table_name_list
                            #print dst_table_name_list
                            for table in src_table_name_list:
                                if table in dst_table_name_list:
                                #if dst_table_name_list.index(table):
                                    #pass
                                    #print table
                                    #print src_table_name_list
                                    #print dst_table_name_list
                                    #del dst_table_name_list[dst_table_name_list.index(table)]
                                    #src_table_name_list.remove(table)
                                    #dst_table_name_list.remove(table)
                                    sl.remove(table)
                                    dl.remove(table)
                                else:
                                    continue
                            #print src_table_name_list
                            #print dst_table_name_list
                            if len(sl) > 0 or len(dl) > 0:
                                print s,"master uniq table: ",sl
                                print d,"slave uniq table: ",dl
                            #sys.exit()
    

def get_avg_of_row():
    f=open('test.txt',"a")
    co=1
    f.writelines("table_name\tdata_sum\tindex_sum\tsum\trow_number\tavg_row\n")
    #循环所有数据库实例
    for s in dictionary.keys():
        #if s.split('-')[0] == "sa":
        #    continue
        #只获取所有master服务器的信息并进行连接
        if s.split('-')[1] == "master":
            #f.writelines("============" + s + "==================" + "\n")
            conn=MySQLdb.connect(host=cf.get(s,"ip"),port=int(cf.get(s,"port")),user="myadmin",passwd="mysupp@xmcx")
            cursor=conn.cursor()

            #实例内所有数据库循环
            for database in eval(cf.get(s,"databases")):
                cursor.execute("use %s" % database)

                #数据库内所有日表、月表数据统计
                #日表、月表数量太多 只取最大数据的一个表的值,然后乘以需要保留的天数
                for tb_name in dictionary[s]['db'][database]['m_tb_uniq_name']+dictionary[s]['db'][database]['d_tb_uniq_name']:
                    cursor.execute("select max(DATA_LENGTH),INDEX_LENGTH,TABLE_NAME from information_schema.tables where table_schema = '%s' and table_name like '%s%%'" % (database,tb_name))
                    (data_sum,index_sum,table_name)=cursor.fetchall()[0]
                    cursor.execute("select count(*) from %s.%s" % (database,table_name))
                    row_number=int(cursor.fetchall()[0][0])
                    if row_number == 0:
                        continue
                    sum=data_sum+index_sum
                    cursor.execute("select AVG_ROW_LENGTH from information_schema.tables where table_schema = '%s' and table_name = '%s';" % (database,table_name))
                    data_avg_row=cursor.fetchall()[0][0]
                    avg_row=data_avg_row+index_sum/row_number
                    f.writelines(table_name + "\t" + str(data_sum) + "\t" + str(index_sum ) + "\t" + str(sum) + "\t" + str(row_number) + "\t" + str(avg_row) + "\n")
                    cursor.execute("desc %s.%s" % (database,table_name))
                    #print co,database,table_name
                   # print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                   # print "|%20s | %15s | %4s | %4s | %10s | %15s |" % ("Field","Type","Null","Key","Default","Extra")
                   # print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                    sum=0
                    for line in cursor.fetchall():
                        #     print "|%20s | %15s | %4s | %4s | %10s | %15s |" % (line[0],line[1],line[2],line[3],line[4],line[5])
                        type=line[1]
                        if type.split('(')[0] == 'int':
                            leng=4
                        elif type.split('(')[0] == 'tinyint':
                            leng=1
                        elif type.split('(')[0] == 'bigint':
                            leng=8
                        elif type.split('(')[0] == 'smallint':
                            leng=2
                        elif type.split('(')[0] == 'decimal':
                            leng=8
                        elif type.split('(')[0] == 'datetime':
                            leng=8
                        elif type.split('(')[0] == 'timestamp':
                            leng=4
                        elif type.split('(')[0] == 'varchar' or type.split('(')[0] == 'char':
                            leng=int(type.split('(')[1].strip(')'))*3
                            #print type.split('(')[0],leng
                        else:
                            print "unknown type",type
                        #print type,leng
                        sum+=leng
                    #print sum
                    print co,database,table_name,sum

                        #print line[0],line[1]
                   # print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                   # print ""
                    co+=1

                #数据库内所有除日表、月表的数据统计
                for table_name in dictionary[s]['db'][database]['tb']:
                    #判断是否是日表或者月表，如果是，则跳过该表，继续
                    if table_name in dictionary[s]['db'][database]['m_tb_name'] or table_name in  dictionary[s]['db'][database]['d_tb_name']:
                        continue
                    #判断是否是基础表（对于视图、触发器等 跳过）
                    cursor.execute("select TABLE_TYPE,ENGINE from information_schema.tables where table_schema = '%s' and table_name = '%s';" % (database,table_name))
                    (table_type,table_engine)=cursor.fetchall()[0]
                    if table_type != 'BASE TABLE':
                        continue
                    elif table_engine == 'MEMORY':
                        continue
                    
                    #获取表行数,没有记录的表跳过
                    cursor.execute("select count(*) from %s.%s" % (database,table_name))
                    row_number=int(cursor.fetchall()[0][0])
                    if row_number == 0:
                        continue

                    #获取表数据大小
                    cursor.execute("select DATA_LENGTH,INDEX_LENGTH from information_schema.tables where table_schema = '%s' and table_name = '%s';" % (database,table_name))
                    (data_sum,index_sum)=cursor.fetchall()[0]
                    sum=data_sum+index_sum
                    cursor.execute("select AVG_ROW_LENGTH from information_schema.tables where table_schema = '%s' and table_name = '%s';" % (database,table_name))
                    data_avg_row=cursor.fetchall()[0][0]
                    avg_row=data_avg_row+index_sum/row_number
                    f.writelines(table_name + "\t" + str(data_sum) + "\t" + str(index_sum ) + "\t" + str(sum) + "\t" + str(row_number) + "\t" + str(avg_row) + "\n")
                    cursor.execute("desc %s.%s" % (database,table_name))
                    #print co,database,table_name
                    #print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                    #print "|%20s | %15s | %4s | %4s | %10s | %15s |" % ("Field","Type","Null","Key","Default","Extra")
                    #print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                    sum=0
                    for line in cursor.fetchall():
                        #    print "|%20s | %15s | %4s | %4s | %10s | %15s |" % (line[0],line[1],line[2],line[3],line[4],line[5])
                        #print line[0],lin[1]
                        type=line[1]
                        if type.split('(')[0] == 'int':
                            leng=4
                        elif type.split('(')[0] == 'tinyint':
                            leng=1
                        elif type.split('(')[0] == 'bigint':
                            leng=8
                        elif type.split('(')[0] == 'smallint':
                            leng=2
                        elif type.split('(')[0] == 'decimal':
                            leng=8
                        elif type.split('(')[0] == 'datetime':
                            leng=8
                        elif type.split('(')[0] == 'timestamp':
                            leng=4
                        elif type.split('(')[0] == 'varchar' or type.split('(')[0] == 'char':
                            leng=int(type.split('(')[1].strip(')'))*3
                            #print type.split('(')[0],leng
                        else:
                            print "unknown type",type
                        #print type,leng
                        sum+=leng
                    #print sum
                    print co,database,table_name,sum
                    #print "+" + "-"*21 + "+" + "-"*17 + "+" + "-"*6 + "+" + "-"*6 + "+" + "-"*12 + "+" + "-"*17 + "+"
                    #print ""
                    co+=1
            cursor.close() 
            conn.close() 
    f.close()
    print co
                    
#def get_sql_shll():
#    while True:
#        printf "efetion@db_tool|"



#get_slave_stat()
#get_rep_stat()
#get_all_tb_info()
get_avg_of_row()
#get_sql_shll()
#if len(sys.argv) > 1:
#    print "ok"
#    sys.exit()
#else:
#    sys.exit()
