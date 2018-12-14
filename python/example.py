# $language = "python"
# $interface = "1.0"
host = "221.176.13.62"
user = "cmcc"
port = "18592"
import time
import ConfigParser
TODAY = time.strftime("%Y-%m-%d",time.localtime(time.time()))
#crt.Dialog.MessageBox("SecureCRT version is:" + crt.Version)
cf = ConfigParser.ConfigParser()
second_password = "!#%fetion0@$^"

class Loadblance():
    def __init__(self,host):
        self.host = host
        self.isPass2 = True
        self.ssh_protocol = "SSH2"
        self.su_command = "enable"
        self.command_list = ["enable", "show interface brief", "show cpu","show memory", "show slb virtual-server", "show ha"]


class Switch():
    def __init__(self,host):
        self.host = host
        self.isPass2 = True
        self.ssh_protocol = "SSH1"
        self.su_command = "super"
        self.command_list = ["super","display interface brief", "display cpu","display memory", "display vrrp"]
        
class Fireware():
    def __init__(self,host):
        self.host = host
        self.isPass = False
        self.ssh_protocol = "SSH1"
        self.su_command = "super"
        self.command_lifst = ["super", "display interface brief", "display cpu","display memory", "display vrrp", "display ip route", "display arp all", "display ospf brief"]

class Inner_fw():
    def __init__(self,host):
        self.host = host
        self.isPass2 = True
        self.ssh_protocol = "SSH1"
        self.su_command = "super"
        self.command_list = ["super", "display interface brief", "display cpu","display memory", "display vrrp", "display ip route", "display arp all", "display ospf brief"]
        
def main():
    cmd = "/SSH2 /L %s /PASSWORD %s /C 3DES /M MD5 %s /P %d" % (user, "cmcc4^Op", host,18592)
    crt.Session.LogFileName = "D:\se.log"
    crt.Session.Log(1)
    crt.Session.Connect(cmd)
    crt.Screen.WaitForString("$",10)
    crt.Screen.Send("ls \n")
    crt.Screen.WaitForString("$",10)
    crt.Screen.Send("exit \n")

fw_list = []
inner_fw_list = []
switch_list = []
loadblance_list = []

def connect(ip,user = "entroot",passwd = "!@#entfetion0$%^",port = 22):
    cmd = "/%s /L %s /PASSWORD %s /C 3DES /M MD5 %s /P %d" % (ip.ssh_protocol,user, passwd, ip, port)
    crt.Session.LogFileame = "F:\se.log"
    crt.Session.Log(1)
    crt.Session.Connect(cmd)
    if(crt.Screen.WaitForString(">", 3) !=  True):
        crt.Dialog.MessageBox("login error")
    
def execute_command(command):
    if(crt.Screen.WaitForString(">", 3) == True):
        crt.Screen.Send(command + "\n")
    elif(crt.Screen.WaitForString("word:") == True):
        crt.Screen.Send(second_password)
    else:
        crt.Dialog.MessageBox("execute command error")
    while(crt.Screen.WaitForString("More ----", 3) == True):
        crt.Screen.SendKeys(" ")

for list in list_list:
    c_name = list.rstrip("_list")
    for host in list:
        ip = c_name(host)
        connect(ip)
        for command in ip.command_list:
            execute_command(command)
