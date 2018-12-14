#!/usr/bin/python
# -*- coding: utf-8 -*-

#Author:zhanghao
#version:1.1
#date:2013-1-28
#This scipt must read configuration from config.ini
#simple config.ini content  like this
#[host_name]
#ip=$ip
#port=$port
#databases=$databases(this is a list like ['a','b'])not necessary

#this is a config.ini example:
#[pro_master_1]
#ip=192.168.1.1
#port=3306
#databases=['db1','db2']


import MySQLdb,sys
import ConfigParser
import re,os
import subprocess
import signal
import time

######## 自动补全 begin ########
#定义程序退出时调用函数的模块
#import atexit
#readline模块
import readline
#自动完成模块
import rlcompleter
#历史命令文件
hist_file=('.histfile')
#绑定tab键和自动补全功能
readline.parse_and_bind('tab: complete')
######## 自动补全 end ########

########设置默认编码为utf8############
reload(sys)
exec("sys.setdefaultencoding('utf-8')")


#日志文件
log_file=('.logfile')
######## 日志装饰器 #########
from time import ctime
def log_fun(func):
    def wrappedFunc(*args,**kwargs):
        log_str='[%s] %s([%s],[%s]) executed \n' % (ctime(),func.__name__,args,kwargs)
        open(log_file,'a').writelines(log_str)
        #hist_str='%s(%s,%s) \n' % (func.__name__,args,kwargs)
        #open(hist_file,'a').writelines(hist_str)
        return func(*args,**kwargs)
    return wrappedFunc
######## 日志装饰器 #########

#some terminal color
green='\033[0;32;22m'
light='\033[0;36;22m'
blue='\033[1;34;22m'
end='\033[0m'
red='\033[1;35;1m'
yellow='\033[1;33;1m'

#you can use your own mysql user and password
user="root"
password='secret'

#change the prompt if you want
#mysql_prompt="\n\033[1;33;1mefetion_db_tool >\033[0m "
#admin_prompt="\n\033[0;32;1mefetion >\033[0m "
#admin_prompt='\n%sefetion > %s' % (blue,end)
#admin_prompt='\nefetion > '
admin_prompt='\ndb_tool > '

#write error log to err.log file
#sys.stderr=open("./err.log","a")
#sys.stderr=open("/dev/null","a")
c_dir=os.path.realpath(sys.path[0])
conf_file=c_dir + "/config.ini"
cf=ConfigParser.ConfigParser()
cf.read(conf_file)
dictionary={}


@log_fun
def e_help():
    print ""
    print "%s The follow instance can be instance's list or tuple (except e_conn) %s" % (light,end)
    print "%s you can give several instance split with comma or just give a list like ['a','b']  %s" % (light,end)
    print '%s e_help/?/help            print help information %s' % (light,end)
    print '%s e_list()/l/list          print all instance%s' % (light,end)
    print "%s e_info('instance')       print all instance's information %s" % (light,end)
    print "%s e_sum('instance')        print instance data sum  %s" % (light,end)
    print '%s e_conn("instance")       connect mysql instance and do something %s' % (light,end)
    print '%s e_exec(cmd,"instance")   connect mysql instance - execute sql - disconnect mysql instance  %s' % (light,end)
    print "%s check_alive('instance')  print alive if instance alive %s" % (light,end)
    print "%s check_conn('instance')   print instance connection state and count  %s" % (light,end)
    print '%s check_slave_stat()/cs    print all slave status %s' % (light,end)
    print '%s check_mysql_version()/cv get all mysql instance server version %s' % (light,end)
    print "%s get_var('var','instance')      print instance's variable  %s" % (light,end)
    print "%s get_stat('stat_name','instance')    print instance's state  %s" % (light,end)
    print "%s change_admin_pwd(corpcode,pwd,'instance')     Change instance's admin user's password   %s" % (light,end)
    print "%s exit/quit/ctrl+c will exit the shell   %s" % (light,end)
    print '%s do_data(instance_name,db="",tb="",file="",resource="txt",action="export",)  when action is export filename default  is instance-db-tb,if you do not indicate a filename %s' % (light,end)

#检测系统是否有某个命令
def detect_command(command=""):
    exists_flag=0
    for cmdpath in os.environ['PATH'].split(':'):
        if os.path.isdir(cmdpath) and command in os.listdir(cmdpath):
            return True
            exists_flag=1
    if not exists_flag:
        return False

#打印所有实例名称函数
@log_fun
def e_list():
    print ""
    instance_list=cf.sections()
    instance_list.sort()
    for instance in instance_list:
        ip=cf.get(instance,"ip")
        port=cf.get(instance,"port")
        print light,"%-15s\t%15s:%s" % (instance,ip,port),end
    print ""
    print light,"There are",len(cf.sections()),"instances you can oprate",end


def do_result(result="",field=""):
    #print "do_result begin"
    length=0
    max_field_length=[0]
    #确定字段数
    #print "result",result
    if not result:
        #print "no result,will exit"
        return 0
    if result[0]:
        field_num=len(result[0])
    #初始化字段最长值为0
    #print field_num
    for i in range(field_num):
        max_field_length.append(0)
    for row in result:
        #确定最长行
        if len(str(row)) > length:
            length=len(str(row))
        #print "最长行",length

        #确定每一列的最长，加起来不够行长度的自动空格补齐
        for i in range(field_num):
            if len(str(row[i])) > max_field_length[i+1]:
                #print field[i][0],len(field[i][0]),"max",max_field_length[i+1]
                max_field_length[i+1]=len(str(row[i]))
            elif len(field[i][0]) > max_field_length[i+1]:
                #print field[i][0],len(field[i][0]),"max",max_field_length[i+1]
                max_field_length[i+1]=len(field[i][0])
        #print "列长",max_field_length

    #print field_num
    #print length
    #print sum(max_field_length)
    #print "field name"
    #print "ok,begin"
    print "+" + "-"*(length-2) +"+"
    c=0
    for field_name in field:
        c+=1
        print "%s%s" % ( "|",str(field_name[0]).ljust(max_field_length[c])),
    #print "|".rjust(length-sum(max_field_length)-24)
    print "|".rjust(length-sum(max_field_length)-field_num*2)
    
    #print query data
    print "+" +"-"*(length-2) + "+"
    for row in result:
        for i in range(field_num):
            print "%s%s" % ( "|",str(row[i]).ljust(max_field_length[i+1])),
        #print "|".rjust(length-sum(max_field_length)-15)
        print "|".rjust(length-sum(max_field_length)-field_num*2)
    print "+" +"-"*(length-2) + "+"

#execute mysql command at one instance or some instances
@log_fun
def e_exec(cmd,*instance_name):
    start_time=time.time()
    if not instance_name:
        instance_name=cf.sections()
    for instance_muti in instance_name:
        if isinstance(instance_muti,list):
            for instance in instance_muti:
                try:
                    conn=e_conn(instance,mode='noninteractive')
                    conn.autocommit(True)
                except Exception,e:
                    print e
                    continue
                cursor=conn.cursor()
                cursor.execute(cmd)
                result=cursor.fetchall()
                field=cursor.description
                rows=int(cursor.rowcount)
                print green,instance,end
                do_result(result=result,field=field)
                stop_time=time.time()
                cost_time=stop_time - start_time
                print rows,"rows affects in set (",round(cost_time,2),"sec)"
                conn.commit()
                cursor.close()
                conn.close()
        else:
            ip=cf.get(instance_muti,"ip")
            port=cf.get(instance_muti,"port")
            conn=e_conn(instance_muti,mode='noninteractive')
            conn.autocommit(True)
            cursor=conn.cursor()
            cursor.execute(cmd)
            result=cursor.fetchall()
            field=cursor.description
            rows=int(cursor.rowcount)
            print green,instance_muti,end
            do_result(result=result,field=field)
            stop_time=time.time()
            cost_time=stop_time - start_time
            print rows,"rows affects in set (",round(cost_time,2),"sec)"
            conn.commit()
            cursor.close()
            conn.close()

#连接实例函数
@log_fun
def e_conn(instance_name,mode="interactive"):
    #print ""
    ip=cf.get(instance_name,"ip")
    port=cf.get(instance_name,"port")
    mysql_prompt='%s[%s:%s]> ' % (instance_name,ip,port)
    try:
        conn=MySQLdb.connect(host=ip,port=int(port),user=user,passwd=password,charset='utf8',connect_timeout=10)
        conn.autocommit(True)
    except Exception,e:
        print '%s can\'t connect %s on  %s:%s %s' % (red,instance_name,ip,port,end)
        print e
        print ""
    if mode != "interactive":
        return conn
    cursor=conn.cursor()
    while True:
        cmd=raw_input(mysql_prompt)
        if cmd == "exit":
            break
        try:
            start_time=time.time()
            cursor.execute(cmd)
        except Exception,e:
            print e
            continue
        result=cursor.fetchall()
        field=cursor.description
        rows=int(cursor.rowcount)
        do_result(result=result,field=field)
        stop_time=time.time()
        cost_time=stop_time - start_time
        print rows,"rows affects in set (",round(cost_time,2),"sec)"
    conn.commit()
    cursor.close()
    conn.close()

#查看所有从库复制状态
@log_fun
def check_slave_stat():
    #print ""
    for s in cf.sections():
        if s.split('-')[-1] == "slave" or s.split('-')[-2] == "slave":
            conn=e_conn(s,mode='noninteractive')
            cursor=conn.cursor()
            cursor.execute("show slave status")
            result=tuple(cursor.fetchall()[0])
            if result[10] != "Yes":
                print yellow,s,end
                print "Slave_IO_Running ",red,result[10],end
            elif result[11] != "Yes":
                print yellow,s,end
                print "Slave_SQL_Running: ",red,result[11],end
            #5.5 result[-8]
            elif result[-6] != 0:
                print yellow,s,end
                print "Seconds_Behind_Master: ",red,result[-6],end
            #5.5 [6]-[-19]
            elif result[6]-result[-17] != 0:
                print yellow,s,end
                print "slave behind master postion: ",red,result[6]-result[-17],end
            else:
                print yellow,"%20s" % s,end,"slave status",green,"ok",end
            cursor.close()
            conn.close()

#获取所有mysql服务器版本
@log_fun
def check_mysql_version():
    #print ""
    #cmd='select @@version'
    #e_exec(cmd,cf.sections())
    for instance in cf.sections():
        conn=e_conn(instance,mode='noninteractive')
        print '%-25s %s %s %s' % (instance,green,conn.get_server_info(),end)

#获取所有配置文件中的实例中的数据库
@log_fun
def db_list():
    instance_list=[]
    s=[]
    #根据实例的第一个破折号前面的名字排除重复实例
    for instance in cf.sections():
        if instance.split('-')[0] not in s:
            s.append(instance.split('-')[0])
            instance_list.append(instance)
    for instance in instance_list:
        e_exec('show databases',instance)
    

#指定一个实例名称，获取指定实例的所有相关信息
@log_fun
def e_info(instance_name):
    print ""
    for i in cf.items(instance_name):
        print i
    

#get all instance data amount
@log_fun
def e_sum(*instance_name):
    sys.stderr=open("./err.log","a")
    cmd="select concat(round(sum((INDEX_LENGTH+DATA_LENGTH)/1024/1024),2),'MB') as data  from information_schema.TABLES"
    if not instance_name:
        e_exec(cmd,cf.sections())
    else:
        for instance in instance_name:
            e_exec(cmd,instance)


#check all instance alive 
@log_fun
def check_alive(*instance_name):
    #too ugly
    #cmd='select " Alive  "'
    if not instance_name:
        for instance in cf.sections():
            try:
                conn=e_conn(instance,mode='noninteractive')
                conn.close()
                print '%-25s %s OK %s' % (instance,green,end)
            except Exception,e:
                continue
    else:
        for instance in instance_name:
            try:
                conn=e_conn(instance,mode='noninteractive')
                conn.close()
                print '%-25s %s OK %s' % (instance,green,end)
            except Exception,e:
                continue

#check all instance connection status
@log_fun
def check_conn(*instance_name):
    cmd='SELECT COMMAND,COUNT(*) TOTAL FROM INFORMATION_SCHEMA.PROCESSLIST GROUP BY COMMAND ORDER BY TOTAL DESC'
    if not instance_name:
        e_exec(cmd,cf.sections()) 
    else:
        for instance in instance_name:
            e_exec(cmd,instance)

@log_fun
def get_var(variable_name,*instance_name):
    cmd="show variables like '%%%s%%'" % variable_name
    if not instance_name:
        e_exec(cmd,cf.sections()) 
    else:
        for instance in instance_name:
            e_exec(cmd,instance)
    

@log_fun
def get_stat(stat_name,*instance_name):
    cmd="show global status like '%%%s%%'" % stat_name
    if not instance_name:
        e_exec(cmd,cf.sections()) 
    else:
        for instance in instance_name:
            e_exec(cmd,instance)

#def performance_stat(*instance_name):

#以下函数为企业业务函数
#修改管理员密码
@log_fun
def change_admin_pwd(corpcode=20001000001,pwd='mop123',*instance_name):
    cmd="update imop_db.imop_admin set md5pwd = md5('%s'),errlogincount = 0 where corpcode = %s and adminname = 'admins';" % (pwd,corpcode)
    if not instance_name:
        print "You must indicate a instance name"
        sys.exit() 
    else:
        for instance in instance_name:
            e_exec(cmd,instance)
 

#导入导出数据
@log_fun
def do_data(instance_name,db="",tb="",file="",resource="txt",action='export'):
    '''just for one instance'''
    ip=cf.get(instance_name,"ip")
    port=cf.get(instance_name,"port")
    #print ip,port
    if not db:
        print "You must have a database name!"

    if not instance_name:
        print "You must indicate a instance name"
        sys.exit() 

    else:
        if resource == "txt":
            #导出/导入文本
            if action == "import":
                cmd="load data local infile '%s' into table %s.%s" % (file,db,tb)
                print cmd
                e_exec(cmd,instance_name)
            else:
                #action is export do this 
                #print db,tb,ip,port
                if not tb:
                    print "%s default output type is txt,so you must indicate a table name or you can change output type with option resource = sql %s" % (yellow,end)
                    return 1
                if detect_command(command="mysql"):
                    if not file:
                        file='%s-%s-%s.txt' % (instance_name,db,tb)
                    cmd="mysql -u%s -p%s -h%s -P%d -N -e 'select * from %s.%s' >%s" % (user,password,ip,int(port),db,tb,file)
                else:
                    print "Your system doesn't have mysql command"
                os.system(cmd)

        elif resource == "sql":
            #导出(mysqldump)/导入(mysql) sql文件
            if action == "import":
                if not file:
                    print "can't find sql file"
                if detect_command(command="mysql"):
                    cmd="mysql -u%s -p%s -h%s -P%s %s < %s" % (user,password,ip,port,db,file)
                    print cmd
                else:
                    print "Your system doesn't have mysql command"
                    sys.exit()
            else:
                if detect_command(command="mysqldump"):
                    if not file:
                        if not tb:
                            file='%s-%s.sql' % (instance_name,db)
                        else:
                            file='%s-%s-%s.sql' % (instance_name,db,tb)
                    cmd="mysqldump -u%s -p%s -h%s -P%s %s %s > %s"  % (user,password,ip,port,db,tb,file)
                else:
                    print "Your system doesn't have mysqldump command"
                    sys.exit()
            os.system(cmd)

        else:
            print "wrong resource"
            return 1



@log_fun
def exit_handler(signo, frame):
    print "\nYou press ctrl + c,we will exit"
    #print "signal number is",signo
    sys.exit()

#定义获取到ctrl +c 信号，进行handler处理
signal.signal(signal.SIGINT, exit_handler)

#def continue_handler(signo, frame):
#    print "You press ctrl + z", signo
#    sys.exit()

#定义获取到ctrl +z 信号，进行handler处理
#signal.signal(signal.SIGTSTP, continue_handler)



#模拟出一个类似shell的工作台
#try:
while True:
    #先清空历史记录，避免重复读取记录
    readline.clear_history()
    #去除历史文件中的重复记录
    s = []
    [ s.append(k) for k in open(hist_file) if k not in s ]
    open(hist_file, 'w').write(''.join(s))
    #读命令历史文件
    try:
        readline.read_history_file(hist_file)
    except:
        pass
    fun_d=raw_input(admin_prompt)
    #如果获取到exit退出
    if fun_d == "exit" or fun_d == "quit":
        break
    #如果没有获取到输入，继续回到工作台
    if not fun_d:
        continue
    if fun_d == "list" or fun_d == "l":
        e_list()
        continue
    if fun_d == "help" or fun_d == "?":
        e_help()
        continue
    if fun_d == "cs":
        check_slave_stat()
        continue
    if fun_d == "cv":
        check_mysql_version()
        continue
    if fun_d == "ca":
        check_alive()
        continue
    #如果获取到输入，直接将输入以函数形式运行
    try:
        eval("%s" % fun_d)
        readline.write_history_file(hist_file)
    except Exception,e:
        print e
        readline.write_history_file(hist_file)
#except KeyboardInterrupt:
#    print "\nGot ctrl +c,exit"
#    sys.exit()


#程序退出时调用readline的功能将历史操作记录写入文件
#atexit.register(readline.write_history_file,hist_file)
sys.exit()
