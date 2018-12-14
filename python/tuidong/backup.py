#!/usr/bin/python
import pexpect,os,sys,time,datetime

starttime=datetime.datetime.now()
today=time.strftime("%Y-%-m-%-d",time.localtime())
local_backup_dir="/backup/"+today
remote_backup_file="/backup/cmcc.tar.gz"
user="cmcc"
passwd="cmcc3Ve8*jndkg#7jykd&8"
expire_day=7

os.path.exists(local_backup_dir) or os.makedirs(local_backup_dir)
os.chdir("/backup")
os.system("find ./ -maxdepth 1 -mtime +%s -exec rm -rf {} \;" % expire_day)
hostlist=['122.11.49.130','122.11.49.131','122.11.49.134']
for host in hostlist:
	host_dir=local_backup_dir+"/"+host
	os.path.exists(host_dir) or os.makedirs(host_dir)
	rcmd="scp -P 17951 %s@%s:%s %s" % (user,host,remote_backup_file,host_dir)
	print rcmd
	outfile=pexpect.run (rcmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
	print outfile
endtime=datetime.datetime.now()
expendtime=(endtime - starttime).seconds
print "this program consumed ",time.strftime('%H:%M:%S',time.gmtime(expendtime)),"time"
