#!/usr/bin/python
# -*- coding: utf-8 -*-
#########################
#   Auther:zhanghao     #
####################################################
#2014-7-23新增一键更新功能                         #
#主要原理为从source host中拷贝目录，然后同步到线上 #
#暂时未添加替换配置文件的功能                      #
####################################################


#####本更新程序包括3个文件 
#####update.py 更新脚本 
#####mod.ini 更新服务器及模块 等配置信息
#####exclude.txt 同步时需要排除的文件 一行一个文件名称

#####配置文件中如果是jar包 mod_name必须和jar包名一样
#####本地文件夹名称必须和模块名称一样，可以是文件夹也可以是tar.gz或者zip包


import sys,os,pexpect,fileinput,paramiko,datetime,time
from ConfigParser import ConfigParser
##########变量设置#################
#开始时间（结束后有个结束时间，两者相减即程序运行时间）
starttime=datetime.datetime.now()
#today="2014-5-21-101110"
today=time.strftime("%Y-%-m-%-d-%-H%-M",time.localtime())

#程序及配置文件所在路径
src_dir_prefix="/home/update/"
#模块信息配置文件
mod_file=src_dir_prefix + "mod.ini"
#同步需要排除的文件
exclude_file=src_dir_prefix + "exclude.txt"

#本地主机同步目录(备份目录）
#dst_dir="/home/backup/" + today + "/"
local_backup_dir_prefix="/home/backup/"

#程序上传目录(上传目录不需加日期 每次替换上次上传的版本)
#upload_dir="/home/update/" + today
upload_dir="/home/update/"

#配置文件多IP分隔符
s_field='|'

#读取配置文件
#模块IP/路径/模块类型
#PS:如果有tomcat 还需指定tomcat路径（重启tomcat服务用）
os.path.exists(mod_file) or sys.exit('can not find module config file %s' % mod_file)
cf=ConfigParser()
cf.read(mod_file)


def helpFunc(a,b,c,d):
    print ""
    print "usage: update.py -m module_name -a action_type"
    print ""
    print "-l will only print all of the mod_name and exit"
    print "module_name provide module_name to update"
    print ""
    print "-A will sync file from  source server to dest server"
    print ""
    print "action type is update|backup|rollback|full_update|test_update"
    print ""
    print "example:  ./update.py -m mod -a update -A"
    print ""
    print "list mod:"
    print cf.sections()
    sys.exit(3)

def verFunc(a,b,c,d):
    print "Ver 0.0.1"
    sys.exit(3)

#日志文件
log_file=('.logfile')
######## 日志装饰器 #########
#from time import ctime
def log_fun(func):
    def wrappedFunc(*args,**kwargs):
        log_str='[%s] %s([%s],[%s]) executed \n' % (time.ctime(),func.__name__,args,kwargs)
        open(log_file,'a').writelines(log_str)
        #hist_str='%s(%s,%s) \n' % (func.__name__,args,kwargs)
        #open(hist_file,'a').writelines(hist_str)
        return func(*args,**kwargs)
    return wrappedFunc
######## 日志装饰器 #########


from optparse import OptionParser
parser = OptionParser(add_help_option=0)
parser.add_option("-h", "--help", action="callback", callback=helpFunc)
parser.add_option("-v", "--version", action="callback", callback=verFunc)
parser.add_option("-m", "--module", action="store", type="string",dest="mod",default="")
parser.add_option("-a", "--action", action="store", type="string",dest="act",default="")
parser.add_option("-A", "--auto", action="store_true",dest="auto")
parser.add_option("-V", "--rollback_version", action="store",dest="version",default="")
parser.add_option("-l", "--list", action="store_true", dest="list")

(options, args) = parser.parse_args()
mod_name=options.mod
action=options.act
version=options.version
auto=options.auto
#print options
print version
try:
    print auto
except:
    auto=False

#如果指定-l，仅列出模块列表 安全退出
if options.list:
    print cf.sections()
    sys.exit(0)


#如果没有指定模块名或者动作,打印错误并退出 
if mod_name or action:
    pass
else:
    print '''you don't have mod_name and action!\nuse -h get some help'''
    sys.exit()

#如果模块不在模块列表中，打印错误信息并退出
if not cf.has_section(mod_name):
    sys.exit("mod_name %s not in mod_list\nmod_list must in \n %s \n\n see %s get more information" % (mod_name,cf.sections(),mod_file))


print starttime

class haixuan():

    def __init__(self,mod_name='',host='',port='',upload_file_prefix='',local_backup_dir='',user='',password='',is_compress=''):
        self.mod_name = mod_name
        self.host = host
        self.user = user
        self.password = password
        self.port = port
        self.is_compress = is_compress
        self.upload_file_prefix = upload_file_prefix
        self.local_backup_dir = local_backup_dir
        #print "upload_dir",upload_dir,"upload_file_prefix",upload_file_prefix,"local_backup_dir",local_backup_dir,"local_backup_dir_prefix",local_backup_dir_prefix,"remote_dst_file",remote_dst_file,"is_compress",is_compress

    @log_fun
    def scp_source_package_to_local(self):
        #一键更新，从远程主机拷贝模块目录 同步到线上目录
        self.is_compress = 'False'
        print "scp_source_package_to_local"
        #如果本地主机有模块目录/jar包或者备份目录有更新包，则可以直接更新 无需从远程主机拷贝目录
        if os.path.exists("%s" %  upload_unzip_dir) or os.path.exists("%s" % upload_dir + mod_name + ".jar") or os.path.exists(local_backup_file_prefix):
            return 0
        #获取source server变量
        if cf.has_option(mod_name,'source_host') and cf.has_option(mod_name,'source_path') and cf.has_option(mod_name,'source_user') and cf.has_option(mod_name,'source_password'):
            if cf.has_option(mod_name,'source_port'):
                source_port = cf.get(mod_name,'source_port')
            else:
                source_port = 22
            source_host = cf.get(mod_name,'source_host')
            source_user = cf.get(mod_name,'source_user')
            source_password = cf.get(mod_name,'source_password')
            source_path =cf.get(mod_name,'source_path')
        #从source_host拷贝jar包（只拷贝时间最近的一个包）
            if type == "jar":
                cmd="cd %s;echo $(ls -rt *.jar|tail -1)" % source_path
                filename=run_command(cmd,user=source_user,port=source_port,password=source_password,host=source_host,stdout="file")
                source_path = cf.get(mod_name,'source_path') + filename
                backup_cmd="scp -q -P%s -r %s@%s:%s %s" % (source_port,source_user,source_host,source_path,upload_dir + mod_name + ".jar")
        #从source_host拷贝模块目录
            else:
                source_path = cf.get(mod_name,'source_path')
                #backup_cmd="scp -q -P %s -r %s@%s:%s %s" % (source_port,source_user,source_host,source_path,upload_unzip_dir)
                backup_cmd="rsync -q -e 'ssh -p %s' -avz --exclude=logs/ --exclude=log/ %s@%s:%s %s" % (source_port,source_user,source_host,source_path+"/",upload_unzip_dir)
            print backup_cmd
            try:
                outfile=pexpect.run (backup_cmd, events={'(?i)password': source_password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
                print outfile
                print ""
            except Exception as e:
                print e
        else:
            sys.exit("Make sure you define source_host/source_path/source_user/source_password")
                
        
        
    @log_fun
    def mv_upload_file_to_backup_dir(self):
        #判断上传目录中是否有压缩包
        #if cf.has_option(mod_name,'is_compress') and cf.get(mod_name,'is_compress') == 'True':
        print "mv_upload_file_to_backup_dir"
        #print self.is_compress
        #如果备份目录有更新包 则不用拷贝
        if os.path.exists(local_backup_file_prefix):
            #print "local_backup_file_prefix" + local_backup_file_prefix +" exists ,we will exit"
            return 0
        else:
            os.path.exists(local_backup_file_prefix) or os.makedirs(local_backup_file_prefix)
        if self.is_compress == 'True':
            if os.path.exists("%s" % self.upload_file_prefix+".tar.gz") or os.path.exists("%s" % self.upload_file_prefix+".zip"):
        #如果是压缩包先解压
        #复制文件到本地同步目录
                if type == "java":
                    os.path.exists(local_backup_dir) or os.makedirs(local_backup_dir)
                    print "chdir",local_backup_dir
                    os.chdir(local_backup_dir)
                    print 'mv %s.tar.gz %s 2>/dev/null||mv %s.zip %s 2>/dev/null' % (self.upload_file_prefix,local_backup_dir,self.upload_file_prefix,local_backup_dir)
                    os.system("mv %s.tar.gz %s 2>/dev/null||mv %s.zip %s 2>/dev/null " % (self.upload_file_prefix,local_backup_dir,self.upload_file_prefix,local_backup_dir))
                elif type == "jar":
                    os.chdir(local_backup_file_prefix)
                    print "chdir",local_backup_dir
                    os.system("mv  %s %s" % (upload_dir + mod_name + ".jar",local_backup_file_prefix))
                    print "mv %s %s" % (upload_dir + mod_name + ".jar",local_backup_file_prefix)
                elif type == "c" or type == "php":
                    os.path.exists(self.local_backup_dir) or os.makedirs(self.local_backup_dir)
                    os.chdir(self.local_backup_dir)
                    os.system("mv %s.tar.gz %s 2>/dev/null||mv %s.zip %s 2>/dev/null " % (self.upload_file_prefix,self.local_backup_dir,self.upload_file_prefix,self.local_backup_dir))
                    print "mv %s.tar.gz %s 2>/dev/null||mv %s.zip %s 2>/dev/null"
                else:
                    print "mod_type error"
                    sys.exit()
                #print os.path.abspath(os.path.curdir)
                os.chdir(local_backup_dir)
                print "tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip 2>/dev/null" % (mod_name,mod_name)
                os.system("tar xzf %s.tar.gz 2> /dev/null||unzip %s.zip >/dev/null 2>&1" % (self.mod_name,self.mod_name))
                os.system("rm -f %s.tar.gz 2>/dev/null;rm -f %s.zip >/dev/null 2>&1" % (self.mod_name,self.mod_name))
                print "rm -f %s.tar.gz 2>/dev/null;rm -f %s.zip 2>/dev/null" % (mod_name,mod_name)
                if type == "c":
                    os.system("[ -d %s ] && mv %s/* ./ && rmdir %s" % (self.mod_name,self.mod_name,self.mod_name))
            else:
                print "you compress flag is True,but your " + upload_dir + "can't find " + self.mod_name + ".zip or " + self.mod_name + ".tar.gz"
                sys.exit()
        elif type == "jar":
            os.chdir(local_backup_file_prefix)
            print "chdir",local_backup_dir
            if os.path.exists("%s" % upload_dir + mod_name + ".jar"):
                print "mv %s %s" % (upload_dir + mod_name + ".jar",local_backup_file_prefix)
                os.system("mv %s %s" % (upload_dir + mod_name + ".jar",local_backup_file_prefix))
            else:
                print upload_dir + " can't find " + self.mod_name + ".jar"
                sys.exit()
        else:
            #如果没有压缩包 是否有文件夹
            if os.path.exists("%s" %  upload_unzip_dir):
                os.system("mv  %s %s" % (upload_unzip_dir,self.local_backup_dir))
            #如果都没有 退出
            else:
                print upload_dir + " can't find " + self.mod_name + " directory"
                sys.exit()



    @log_fun
    def stop_program(self):
        #关闭应用
        #print "echo stop start"
        if type == "java":
            self.webapp=cf.get(self.mod_name,"tomcat_path")
            rcmd='''pid=`ps aux|grep %s|grep -v grep|awk '{print $2}'`;[ -n "$pid" ] && kill -9 $pid ; rm -rf %s/work/Catalina/''' % (self.webapp,self.webapp)
        elif type == "jar":
            rcmd='''pid=`ps aux|grep %s|grep -v grep|awk '{print $2}'`;[ -n "$pid" ] && kill -9 $pid ''' % (self.mod_name)
        elif type == "c":
            self.pname=remote_dst_file.split("/")[-1]
            rcmd='''pid=`ps aux|grep %s|grep -v grep|awk '{print $2}'`;[ -n "$pid" ] && kill -9 $pid '''  % self.pname
        elif type == "php":
            rcmd='''/etc/init.d/nginx stop;/etc/init.d/php-fpm stop'''
        else:
            return 1
        run_command(rcmd)

    @log_fun
    def start_program(self):
        #启动应用
        #self.time=
        if start_cmd:
            rcmd=start_cmd
        elif type == "java":
            rcmd='source /etc/profile ; %s/bin/startup.sh' % self.webapp
        elif type == "c":
            rcmd='''cd %s ;find ./bin  -path "*bak" -prune -o  -type f -exec test -x {} \; -a -exec ls {} \;|xargs -I a nohup a>nohup.out 2>&1 &''' % remote_dst_file
        elif type == "jar":
            rcmd='''source /etc/profile ; cd %s ; nohup java -jar $(ls -rt *.jar|tail -1)>nohup.out 2>&1 &''' % remote_dst_file
        elif type == "php":
            rcmd='''/etc/init.d/nginx start;/etc/init.d/php-fpm start'''
        else:
            return 1
        run_command(rcmd)

    @log_fun
    def check_status(self):
        #检测应用启动后是否报错
        print "check"
        if type == "java":
            #rcmd='grep -e -i -A500 '%s' %s/logs/catalina.out|grep -e 'Exception|error' %s/logs/catalina.out ' % (self.time,self.webapp)
            rcmd='''tail -n 2000 '%s' %s/logs/catalina.out|grep -i -A50 'Exception|error' %s/logs/catalina.out ''' % (self.webapp,self.webapp)
        elif type == "jar":
            rcmd='''tail -n 2000 '%s' %s/logs/err|grep -i -A50 'Exception|error' %s/logs/err ''' % (self.webapp,self.webapp)
        else:
            return 1
        run_command(rcmd)

    @log_fun
    def update(self):
        #同步更新到远程服务器
        if auto:
            self.scp_source_package_to_local()
        self.mv_upload_file_to_backup_dir()
        self.stop_program()
        rcmd='[ -d %s ] || mkdir -p %s' %  (remote_dst_file,remote_dst_file)
        #print rcmd
        run_command(rcmd)
        rcmd="rsync -e 'ssh -p %s' -avz --exclude-from=%s %s %s@%s:%s" % (self.port,exclude_file,local_backup_file_prefix,self.user,self.host,remote_dst_file+"/")
        print rcmd
        outfile=pexpect.run (rcmd, events={'(?i)password': self.password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
        print outfile
        print ""
        self.start_program()

    @log_fun
    def backup(self):
        #备份操作
        print "backup start"
        os.path.exists(local_backup_file_prefix) or os.makedirs(local_backup_file_prefix)
        #backup_cmd="scp -P %s -r %s@%s:%s %s" % (self.port,self.user,self.host,remote_dst_file,local_backup_file_prefix)
        backup_cmd="rsync -e 'ssh -p %s' -avz --exclude=logs/  %s@%s:%s %s" % (self.port,self.user,self.host,remote_dst_file,local_backup_file_prefix)
        print backup_cmd
        outfile=pexpect.run (backup_cmd, events={'(?i)password': self.password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
        print outfile
        print ""
        print "%s backup successful!" % self.mod_name
        sys.exit()

    @log_fun
    def rollback(self,version=version):
        #回滚
        #如果没有指定版本，找出时间最近的一次版本进行回滚
        #print "start rollback"
        if not version:
            local_backup_mod_dir=local_backup_dir_prefix + mod_name + "/"
            cmd='''ls -rt %s|tail -1''' % local_backup_mod_dir
            version=os.popen(cmd).read().rstrip()
        #回滚目录
        self.back_dir=local_backup_dir_prefix + mod_name + "/" + version + "/"
        self.stop_program()
        rcmd="rsync -e 'ssh -p %s' -avz  --exclude-from=%s %s %s@%s:%s" % (self.port,exclude_file,self.back_dir + mod_name,self.user,self.host,remote_dst_file+"/")
        print rcmd
        sys.exit()
        outfile=pexpect.run (rcmd, events={'(?i)password': self.password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
        print outfile
        print ""
        self.start_program()

    @log_fun
    def full_update(self):
        #全量更新
        if auto:
            self.scp_source_package_to_local()
        self.mv_upload_file_to_backup_dir()
        self.stop_program()
        self.exclude_file=""
        rcmd="rsync -e 'ssh -p %s' -avz --exclude-from=%s %s %s@%s:%s" % (self.port,self.exclude_file,local_backup_file_prefix,self.user,self.host,remote_dst_file+"/")
        print rcmd
        outfile=pexpect.run (rcmd, events={'(?i)password': self.password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
        print outfile
        print ""
        self.start_program()


    @log_fun
    def test_update(self):
        if auto:
            self.scp_source_package_to_local()
        self.mv_upload_file_to_backup_dir()
        rcmd="rsync -e 'ssh -p %s' -avz --dry-run --exclude-from=%s %s %s@%s:%s" % (self.port,exclude_file,local_backup_file_prefix,self.user,self.host,remote_dst_file+"/")
        print rcmd
        outfile=pexpect.run (rcmd, events={'(?i)password': self.password+'\n','continue connecting (yes/no)?':'yes\n'},timeout=None)
        print outfile
        #print start_cmd
        #if start_cmd:
        #    print "ok",start_cmd
        #else:
        #    print "not ok"
        print ""

        

host_list=cf.get(mod_name,'ip').split(s_field)
if cf.has_option(mod_name,'user'):
    user_list=cf.get(mod_name,'user').split(s_field)
if cf.has_option(mod_name,'password'):
    password_list=cf.get(mod_name,'password').split(s_field)
if cf.has_option(mod_name,'port'):
    port_list=cf.get(mod_name,'port').split(s_field)
#print host_list
for host in host_list:
    #获取给定模块的主机IP、路径和程序类型
    #获取文件路径和cp路径必须获取模块名后才能确定 所以没写在上面的变量设定中
    #print host
    host_index=host_list.index(host)
    #print host_index
    #print len(host_list)
    try:
        remote_dst_file=cf.get(mod_name,"path")
        type=cf.get(mod_name,"type")
        #如果有端口/用户/密码选项则读取，没有则默认为37815/root/123456
        #如果有多个IP/端口/用户/密码 则根据list中的index查找
        if cf.has_option(mod_name,'user') and len(user_list)>host_index:
            user=user_list[host_index]
        elif cf.has_option(mod_name,'user'):
            user=cf.get(mod_name,'user')
        else:
            user='root'
        if cf.has_option(mod_name,'password') and len(password_list)>host_index:
            password=password_list[host_index]
        elif cf.has_option(mod_name,'password'):
            password=cf.get(mod_name,'password')
        else:
            password='123456'
        if cf.has_option(mod_name,'port') and len(port_list)>host_index:
            port=port_list[host_index]
        elif cf.has_option(mod_name,'port'):
            port=cf.get(mod_name,'port')
        else:
            port=37815
        #判断上传文件是否是压缩包
        if cf.has_option(mod_name,'is_compress') and cf.get(mod_name,'is_compress') == 'True':
            is_compress='True'
        else:
            is_compress='False'
        if cf.has_option(mod_name,'start_cmd'): 
            start_cmd=cf.get(mod_name,'start_cmd')
        else:
            start_cmd=False
        #上传文件名称前缀
        upload_file_prefix=upload_dir + "/" + mod_name
        #解压文件夹
        upload_unzip_dir=upload_dir + "/" + mod_name + "/"
        #同步文件夹名称
        #本地备份文件夹名称（本地和远程模块同步文件夹名称）
        local_backup_dir=local_backup_dir_prefix + mod_name + "/" + today + "/"
        local_backup_file_prefix=local_backup_dir_prefix + mod_name + "/" + today + "/" + mod_name + "/"
        #print upload_dir,upload_file_prefix,upload_unzip_dir,local_backup_dir_prefix,local_backup_dir,is_compress
        #print user,host,password,port
    except Exception as e:
        print e
        sys.exit("mod_name error!")

    #在远程主机上执行命令的函数
    @log_fun
    def run_command(cmd,user=user,port=port,password=password,host=host,stdout="stdout"):
        print cmd
        #print host,port,user,password
        client=paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.load_system_host_keys()
        client.connect(hostname=host, port=port,username=user,password=password)
        stdin,stdout,stderr = client.exec_command(cmd)
        print stderr.read()
        if stdout == "stdout":
            print stdout.read()
        else:
            return stdout.read()
        client.close()
    
    t=haixuan(mod_name=mod_name,host=host,port=port,upload_file_prefix=upload_file_prefix,local_backup_dir=local_backup_dir,user=user,password=password,is_compress=is_compress)
    try:
        eval("t.%s()" % action)
    except Exception as e:
        print e
        print '''this instance doesn't have this method name'''



endtime=datetime.datetime.now()
print "this program consumed %s seconds " % (endtime - starttime)
