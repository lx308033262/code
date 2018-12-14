#!/usr/bin/python
# -*- coding: utf-8 -*-
#log file is /tmp/a.log
#ip file is ip.list
#need transfer file is path variable
#f_host is already have file host

f_host="10.10.150.164"
path="/var/a.txt"
user="root"
pwd="fonoirs"
ssh_newkey='Are you sure you want to continue connecting'
LOGFILE=open("/tmp/a.log","w")
import Queue
import datetime
import sys
import pexpect
import threading
starttime=datetime.datetime.now()

if os.path.isdir(path):
    cmd='scp -r'
else:
    cmd='scp'

def scp_file(local_ip,remote_ip,local_path):
    child=pexpect.spawn('ssh %s@%s' % (user,local_ip))
    child.logfile = LOGFILE
    index=child.expect(['password: ',ssh_newkey,pexpect.TIMEOUT])
    if index == 0:
        child.sendline(pwd)
    elif index == 1:
        child.sendline('yes')
        index=child.expect(['password: ',pexpect.TIMEOUT])
        if index == 0:
            child.sendline(pwd)
    elif index == 2:
        return "time out"
    child.expect('~]# ')

    child.sendline('%s %s %s@%s:%s' % (cmd,local_path,user,remote_ip,local_path))
    index=child.expect(['password: ',ssh_newkey,pexpect.TIMEOUT])
    if index == 0:
        child.sendline(pwd)
    elif index == 1:
        child.sendline('yes')
        index=child.expect(['password: ',pexpect.TIMEOUT])
        if index == 0:
            child.sendline(pwd)
    elif index == 2:
        return "time out"
    child.expect('~]# ')
    child.sendline('exit')
    child.close()
    f_q.put(r_ip)
    f_q.put(ip)
    return 0

f_q=Queue.Queue()
u_q=Queue.Queue()
f_q.put(f_host)
for line in open('ip.list','r'):
    u_q.put(line.strip("\n"))

while True:
    if u_q.empty():
        t.join()
        print "this program consumed %s seconds " % (datetime.datetime.now() - starttime)
        sys.exit()
    ip=f_q.get()
    print "finished",ip
    r_ip=u_q.get()
    print "unfinished",r_ip
    print path
    t=threading.Thread(target=scp_file,args=(ip,r_ip,path))
    t.start()
    if not f_q.empty():
        continue
    t.join()
