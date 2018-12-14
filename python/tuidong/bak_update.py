#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,os,pexpect,fileinput,paramiko,datetime,time
from ConfigParser import ConfigParser

#本地主机源和目录、模块对应IP、模块对应路径文件
#同步排除目录文件、同步用户名、密码等相关变量设定
starttime=datetime.datetime.now()
today=time.strftime("%Y-%-m-%-d",time.localtime())
#today="2011-8-30"
src_dir="/home/scm/tuidong/"+ today
dst_dir="/home/cmcc/tuidong/"+ today
mod_file="/home/cmcc/tuidong/mod.ini"
exclude_file="/home/cmcc/tuidong/exclude.txt"
user="cmcc"
passwd="cmcc3Ve8*jndkg#7jykd&8"
port=17951

#读取配置文件
cf=ConfigParser()
cf.read(mod_file)


def helpFunc(a,b,c,d):
	print ""
	print "usage: update.py -m module_name -a action_type"
	print "-l will only print all of the mod_name and exit"
	print "module_name provide module_name to update"
	print ""
	print "action type is update|backup|rollback|full_update|test_update"
	print ""
	print "list mod:"
	print cf.sections()
	sys.exit(3)

def verFunc(a,b,c,d):
	print "Ver 0.0.1"
	sys.exit(3)



from optparse import OptionParser
parser = OptionParser(add_help_option=0)
parser.add_option("-h", "--help", action="callback", callback=helpFunc)
parser.add_option("-V", "--version", action="callback", callback=verFunc)
parser.add_option("-m", "--module", action="store", type="string",dest="mod",default="")
parser.add_option("-a", "--action", action="store", type="string",dest="act",default="")
parser.add_option("-l", "--list", action="store_true", dest="list")

(options, args) = parser.parse_args()
mod_name=options.mod
action=options.act

#如果指定-l，仅列出模块列表 安全退出
if options.list:
	print cf.sections()
	sys.exit(0)


#如果没有指定模块名或者动作
if mod_name or action:
	pass
else:
	print '''you don't have mod_name and action!\nuse -h get some help'''
	sys.exit()

#如果模块不在模块列表中，打印错误信息并退出
if not cf.has_section(mod_name):
	sys.exit("mod_name %s not in mod_list\nmod_list must in \n %s \n\n see %s get more information" % (mod_name,cf.sections(),mod_file))


#获取给定模块的主机IP、路径和程序类型
#获取文件路径和cp路径必须获取模块名后才能确定 所以没写在上面的变量设定中
try:
	host=cf.get(mod_name,"ip")
	remote_dst_file=cf.get(mod_name,"path")
	type=cf.get(mod_name,"type")
	src_file=src_dir + "/" + mod_name
	dst_file=dst_dir + "/" + mod_name
	local_backup_dir=dst_dir + "/backup"
except:
	sys.exit("mod_name error!")

#在远程主机上执行命令的函数
def run_command(cmd):
	client=paramiko.SSHClient()
	client.load_system_host_keys()
	client.connect(hostname=host, port=port,username=user,password=passwd)
	stdin,stdout,stderr = client.exec_command(cmd)
	print stderr.read()
	print stdout.read()
	client.close()


class tuidong:
		
	def update(self):
		#查看是都有该模块的打包文件
		if os.path.exists("%s" % src_file+".tar.gz") or os.path.exists("%s" % src_file+".zip") or os.path.exists("%s" % dst_file+".tar.gz") or os.path.exists("%s" % dst_file+".zip"):
			pass
		else:
			print src_dir + " does't have " + mod_name + " directory"
			sys.exit()
		if type == "java":
			os.path.exists(dst_dir) or os.makedirs(dst_dir)
			os.chdir(dst_dir)
			try:
				os.system("cp %s.tar.gz %s 2>/dev/null||cp %s.zip %s 2>/dev/null " % (src_file,dst_dir,src_file,dst_dir))
			except:
				pass
			os.system("tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip 2>/dev/null" % (mod_name,mod_name))
			os.system("rm -f %s.tar.gz 2>/dev/null||rm -f %s.zip" % (mod_name,mod_name))
			#判断tomcat程序的路径,先关闭应用，然后更新程序
			self.webapp=cf.get(mod_name,"tomcat_path")
			rcmd='''ps aux|grep %s|grep -v grep|awk '{print $2}'|xargs kill -9;rm -rf %s/work/Catalina/''' % (self.webapp,self.webapp)
			print rcmd
			run_command(rcmd)
		elif type == "c" or type == "php":
			os.path.exists(dst_file) or os.makedirs(dst_file)
			os.chdir(dst_file)
			os.system("cp %s.tar.gz %s 2>/dev/null||cp %s.zip %s 2>/dev/null " % (src_file,dst_file,src_file,dst_file))
			os.system("tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip 2 >/dev/null" % (mod_name,mod_name))
			os.system("rm -f %s.tar.gz 2>/dev/null||rm -f %s.zip 2>/dev/null" % (mod_name,mod_name))
			if type == "c":
				self.pname=remote_dst_file.split("/")[-1]
				rcmd='''bash -c "ps -ef|grep -i %s|grep -v grep|awk '{print $2}'|xargs kill -9"'''  % self.pname
				print rcmd
				run_command(rcmd)
		else:
			print "mod_type error"
			sys.exit()
		#同步更新到远程服务器
		rcmd="rsync -e 'ssh -p 17951' -avz --exclude-from=%s %s %s@%s:%s" % (exclude_file,dst_file+"/",user,host,remote_dst_file+"/")
		print rcmd
		outfile=pexpect.run (rcmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
		print outfile
		print ""
		#重启应用
		if type == "java":
			rcmd='source /etc/profile && %s/bin/startup.sh' % self.webapp
			print rcmd
			run_command(rcmd)
		elif type == "c":
			rcmd='''cd %s && ./bin/* &''' % remote_dst_file
			print rcmd
			run_command(rcmd)

	def backup(self):
	#备份操作
		os.path.exists(local_backup_dir) or os.makedirs(local_backup_dir)
		backup_cmd="scp -P 17951 -r %s@%s:%s %s" % (user,host,remote_dst_file,local_backup_dir)
		print backup_cmd
		outfile=pexpect.run (backup_cmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
		print outfile
		print ""
		print "%s backup successful!" % mod_name

	def rollback(self):
		#回滚
		rcmd="rsync -e 'ssh -p 17951' -avz --delete --exclude-from=%s %s %s@%s:%s" % (exclude_file,local_backup_dir+"/"+mod_name+"/",user,host,remote_dst_file+"/")
		print rcmd
		outfile=pexpect.run (rcmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
		print outfile
		print ""

	def full_update(self):
		self.exclude_file=""
		rcmd="rsync -e 'ssh -p 17951' -avz --exclude-from=%s %s %s@%s:%s" % (self.exclude_file,dst_file+"/",user,host,remote_dst_file+"/")
		print rcmd
		outfile=pexpect.run (rcmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
		print outfile
		print ""

	def test_update(self):
		#仅测试 不真正更新
		if os.path.exists("%s" % src_file+".tar.gz") or os.path.exists("%s" % src_file+".zip") or os.path.exists("%s" % dst_file+".tar.gz") or os.path.exists("%s" % dst_file+".zip"):
			pass
		else:
			print src_dir + " does't have " + mod_name + " directory"
			sys.exit()
		if type == "java":
			os.path.exists(dst_dir) or os.makedirs(dst_dir)
			os.chdir(dst_dir)
			os.system("cp %s.tar.gz %s 2>/dev/null||cp %s.zip %s 2>/dev/null" % (src_file,dst_dir,src_file,dst_dir))
			os.system("tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip 2>/dev/null" % (mod_name,mod_name))
			os.system("rm -f %s.tar.gz 2>/dev/null|rm -f %s.zip 2>/dev/null" % (mod_name,mod_name))
		elif type == "c" or type == "php":
			os.path.exists(dst_file) or os.makedirs(dst_file)
			os.chdir(dst_file)
			try:
				os.system("cp %s.tar.gz %s 2>/dev/null||cp %s.zip %s 2>/dev/null " % (src_file,dst_file,src_file,dst_file))
			except:
				pass
			os.system("tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip 2>/dev/null" % (mod_name,mod_name))
			os.system("rm -f %s.tar.gz 2>/dev/null|rm -f %s.zip 2>/dev/null" % (mod_name,mod_name))
		else:
			print "mod_type error"
			sys.exit()
		rcmd="rsync -e 'ssh -p 17951' -avz -n --exclude-from=%s %s %s@%s:%s" % (exclude_file,dst_file+"/",user,host,remote_dst_file+"/")
		print rcmd
		outfile=pexpect.run (rcmd, events={'(?i)password': passwd+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
		print outfile
		print ""


t=tuidong()
try:
	eval("t.%s()" % action)
except:
	print ""
	print '''this instance doesn't have this method name'''

endtime=datetime.datetime.now()
print "this program consumed %s seconds " % (endtime - starttime)
