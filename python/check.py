# $language = "python"
# $interface = "1.0"

import os
import time
import re,ConfigParser
#import glob

TODAY = time.strftime("%Y-%m-%d",time.localtime(time.time())) 
second_password = "!#%fetion0@$^"

os.path.exists or os.makedirs("F:\\xunjian\\" + TODAY)
final_file="F:\\xunjian\\" + TODAY  + "\\" + "statistics.txt"
f=open(final_file,"a")

expr_file="expr.ini"
#files=glob.glob("*.log")

cf=ConfigParser.ConfigParser()
cf.read(expr_file)

fw_list = ["172.16.4.139", "172.16.4.140"]
inner_fw_list = ["172.16.4.135", "172.16.4.136"]
switch_list = ["172.16.4.133", "172.16.4.134", "172.16.4.137", "172.16.4.138", "172.16.4.147", "172.16.4.148", "172.16.4.151", "172.16.4.152", "172.16.4.153", "172.16.4.154","172.16.4.141", "172.16.4.142", "172.16.4.129", "172.16.4.130", "172.16.4.145", "172.16.4.146"]
#loadblance_list = ["172.16.4.132", "172.16.4.149", "172.16.4.150", "172.16.4.131"] 
list_list=[  "inner_fw_list", "fw_list", "switch_list"]
#"loadblance_list",

def connect(ip,user = "entroot",passwd = "!@#entfetion0$%^",port = 22):
    cmd = "/%s /L %s /PASSWORD %s /C 3DES /M MD5 %s /P %d" % (ssh_protocol,user, passwd, ip, port)
    global filename
    filename = str("F:\\xunjian\\" + TODAY + "\\" + ip + ".log")
    crt.Session.LogFileName = filename
    #crt.Dialog.MessageBox(str(filename))
    crt.Session.Log(1)
    #crt.Session.LogFileName = "F:\se.log"
    #crt.Dialog.MessageBox(cmd)
    crt.Session.Connect(cmd)
    if(crt.Screen.WaitForString(">", 3) !=  True):
        crt.Dialog.MessageBox("login error")


        
def execute_command(command):
        
    crt.Screen.WaitForString(">", 1)
    crt.Screen.Send(command + "\n")
    
        
    while(crt.Screen.WaitForString("More ----", 2) == True):
        crt.Screen.Send(" ")
          
for list in list_list:
    type_name = list.rstrip("_list")

    if type_name == "loadblance":
        ssh_protocol="SSH2"
        exit_command="exit"
    else:
        ssh_protocol="SSH1"
        exit_command="quit"
        
    if type_name == "fw":
        command_list = ["super", "display interface", "display cpu","display mem", "display vrrp", "display ip rout", "display arp all", "display ospf brief"]
    elif type_name == "inner_fw":
        command_list = ["super", second_password, "\r", "display interface ", "display cpu", "display vrrp", "display ip rout", "display arp", "display ospf brief", "system-view", "display mem"]
   # elif type_name == "loadblance":
   #     command_list = ["enable", second_password, "\r", "show interface brief", "show cpu","show mem", "show slb virtual-server", "show ha"]
    elif type_name == "switch":
        command_list = ["super", second_password, "\r", "display interface brief", "display cpu","display mem", "display vrrp"]
    else:
        crt.Dialog.MessageBox("wrong type name")


    #crt.Dialog.MessageBox(list)
    for ip in eval(list):
        #crt.Dialog.MessageBox("for ip in:" + list)
        #crt.Dialog.MessageBox("list name is: " + list)
        #crt.Dialog.MessageBox(ip)
        connect(ip)
        for command in command_list:
            execute_command(command)
            #crt.Dialog.MessageBox(command)
        #execute_command(exit_command)
        #crt.Quit()
        crt.Screen.Send(exit_command)
        crt.Session.Disconnect()
        #continue
        f.write('================  ' + ip + '================\r\n')
        if cf.has_section(ip):
            sec_name=ip
        else:
            sec_name=type_name
        for opt in cf.options(sec_name):
            f.write('===================  '+ opt + '  =============\r\n')
            expr_list=eval(cf.get(sec_name,opt))
            for expr in expr_list:
                com=re.compile(expr)
                for line in open(filename):
                    if com.search(line):
                        f.writelines(line)


crt.Quit()
