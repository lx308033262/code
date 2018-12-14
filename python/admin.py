# $language = "python"
# $interface = "1.0"

import os
#import time
import re
#TODAY = time.strftime("%Y-%m-%d",time.localtime(time.time())) 
db_filename="db-server"
mod_filename="mod-server"

mod_list=[]
host_list=[]
#mod_line_list=[]

oprate = crt.Dialog.Prompt("choice action you want(tcpdump or watchlog)")
if oprate == "tcpdump"
    mod_name = crt.Dialog.Prompt("Please input mod_name")
    condition = crt.Dialog.Prompt("Please input tcpdump parameter")
    rexp=re.compile("^" + mod_name + "[0-9][0-9]")
    for line in open(mod_filename):
        if rexp.search(line):
            rex=re.compile("\s+")
            l_list=rex.split(line)
            mod_list.append(l_list[0])
            mod_sub_name=l_list[0]
            host=l_list[1]
            #host_list.append(l_list[1])
            #mod_line_list.append(line)
            #mod_sub_name=l_list[0]
            #mod_host=l_list[1]
            #for i in range(len(mod_list)):
            tiaoban_connect()
            connect(user="root",ip=host)
            execute_command("tcpdump %s -vv -s 0 -w %s" % (condition,mod_sub_name + ".cap"))
                
            
def tiaoban_connect(ip = "221.176.13.62", user = "cmcc", passwd = "cmcc4^Op", port = 18592):
    cmd = "/%s /L %s /PASSWORD %s /C 3DES /M MD5 %s /P %d" % ("SSH2",user, passwd, ip, port)
    crt.Session.Connect(cmd)
    if(crt.Screen.WaitForString("$", 3) !=  True):
        crt.Dialog.MessageBox("login error")
        
def execute_command(command):
    if(crt.Screen.WaitForString("$",2)):
        crt.Screen.Send(command + "\n")
    elif(crt.Screen.WaitForString("#",2)):
        crt.Screen.Send(command + "\n")

    #crt.Screen.WaitForString("$2d", 1)
    #crt.Screen.Send(command + "\n")

def connect(user="cmcc",ip="")
    execute_command("ssh -l %s %s" % (user,ip))
    crt.Screen.WaitForString("word:", 5)
    crt.Screen.Send("cmcc4^Op" + "\n")
    crt.Screen.Send("\r" + "\n")
    if user == "root":
        crt.Screen.WaitForString("$", 5)
        crt.Screen.Send("su -" + "\n")
        crt.Screen.WaitForString("word:", 5)
        crt.Screen.Send("root^*Nm" + "\n")
        crt.Screen.Send("\r" + "\n")
