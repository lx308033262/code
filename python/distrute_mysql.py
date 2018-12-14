#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
#自动分发mysql系统


username="root"
#password="izptec.f2c"
password="Bf1ceb09"
port=22
#mysql_32_package="mysql-advanced-5.5.20-linux2.6-x86_64.tar.gz"
#源主机mysql路径
from_path="/usr/local/src/"
mysql_32_package="mysql-5.6.17-linux-glibc2.5-x86_64.tar.gz"
mysql_64_package="mysql-5.6.17-linux-glibc2.5-x86_64.tar.gz"
#目标主机IP地址
to_host="123.56.100.89"
#目标主机mysql路径
to_path="/usr/local/"
#目标主机mysql目录名称
to_dir='mysql'
default_my_conf="/my.cnf"
my_conf_4G="/my.cnf"
my_conf_8G="/my.cnf"
my_conf_16G="/my.cnf"
print 'set variables ok'


import sys,time
import paramiko
print 'python module import ok'

#登录某台主机 执行命令函数
def exec_commands(host="",command=""):
    if not host or not command:
        print "You muse indicate a hostname and an command"
        sys.exit()
    else:
        paramiko.util.log_to_file('paramiko.log')
        s=paramiko.SSHClient()
        s.load_system_host_keys()
        s.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        s.connect(hostname=host,username=username,password=password,port=port)
        stdin,stdout,stderr=s.exec_command(command)
        print 'exec command ' + command + ' ok'
        return stdout.read().strip('\n')
        s.close()
  #打印所有过程


#检测操作系统位数，判断是用32位mysql还是使用64位mysql
def detect_bit(host=to_host):
    global bit,package
    bit=exec_commands(host=host,command="getconf LONG_BIT")
    if bit == "32":
        package=mysql_32_package
    elif bit == "64":
        package=mysql_64_package
    else:
        print "unknow machine bit,we will exit,please check you machine"
        sys.exit()
        
#检测系统内存大小，决定mysql使用的配置文件
def detect_mem(host=to_host):
    global my_conf
    mem=exec_commands(host=host,command="awk '/MemTotal/ {print $2/1024}' /proc/meminfo |cut -d. -f1")
    if bit == 32:
        my_conf=default_my_conf
    else:
        if mem < 4000:
            my_conf=default_my_conf
        elif mem > 4000 and mem < 7500:
            my_conf=my_conf_4G
        elif mem > 7500 and mem < 14000:
            my_conf=my_conf_8G
        else:
            my_conf=my_conf_16G

#传输文件函数
def transfer_file(from_path="",to_host=to_host,to_path=""):
    t=paramiko.Transport((to_host,port))
    t.connect(username=username,password=password)
    sftp=paramiko.SFTPClient.from_transport(t)
    sftp.put(from_path,to_path)
    sftp.close()
    t.close()

#def check_package():


#启动远程mysql服务的函数
def start_remote_mysql(host=to_host):
    #添加mysql用户
    exec_commands(host=host,command="useradd mysql")
    #解压mysql压缩包 并改名
    uncompress_command="cd " + to_path + "; tar xzf " + package + ";mv mysql-*/ " + to_dir 
    exec_commands(host=host,command=uncompress_command)
    #指定mysql路径
    mysql_dir=to_path+to_dir
    #拷贝mysql配置文件
    mv_cmd="cp -a " + to_path + "my.cnf " + mysql_dir + "/"
    exec_commands(host=host,command=mv_cmd)
    #mv_cmd="mv " + to_path + "my.cnf " + "/etc/"
    #exec_commands(host=host,command=mv_cmd)
    #安装mysql用户和权限库
    install_db_command="cd " + mysql_dir + ' && ./scripts/mysql_install_db --defaults-file=' + mysql_dir + '/my.cnf >/tmp/a.log 2>&1 &'
    exec_commands(host=host,command=install_db_command)
    time.sleep(90)
    #修改mysql 目录权限
    chown_command="chown -R root.mysql " + mysql_dir
    exec_commands(host=host,command=chown_command)
    chown_command="chown -R mysql.mysql " + mysql_dir + "/data"
    exec_commands(host=host,command=chown_command)
    #启动mysql服务
    start_command="cd " + mysql_dir + ";nohup ./bin/mysqld_safe --defaults-file=./my.cnf --user=mysql  > /dev/null 2>&1 &"
    exec_commands(host=host,command=start_command)
    time.sleep(10)
    #删除二进制包
    remove_command="rm -f " + to_path + package
    exec_commands(host=host,command=remove_command)
    #检测进程是否存在
    exec_commands(host=host,command="ps aux|grep mysql")
    return "start mysql ok"

detect_bit()
detect_mem()
print "detect system information ok"
transfer_file(from_path=from_path+package,to_path=to_path+package)
print "transfer package ok"
transfer_file(from_path=my_conf,to_path=to_path+"my.cnf")
print "transfer my.cnf ok"
start_remote_mysql()
print "start mysql ok"

