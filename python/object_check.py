# $language = "python"
# $interface = "1.0"

import time
TODAY = time.strftime("%Y-%m-%d",time.localtime(time.time()))
second_password = "!#%fetion0@$^"

def network_device():
    self.ip = ""
    self.port = 22
    self.ssh_protocol = "SSH1"
    self.user="entroot"
    self.password="!@#entfetion0$%^"
    self.isPass2 = True
    def connect():
        cmd = "/%s /L %s /PASSWORD %s /C 3DES /M MD5 %s /P %d" % (self.ssh_protocol,self.user, self.password, self.ip, self.port)
        crt.Session.LogFileame = "F:\" + self.ip + TODAY + "se.log"
        crt.Session.Log(1)
        crt.Session.Connect(cmd)
        if(crt.Screen.WaitForString(">", 3) !=  True):
            crt.Dialog.MessageBox("login error")
    
    def execute_command(command):
        if(crt.Screen.WaitForString(">", 3) == True):
            crt.Screen.Send(command + "\n")
        elif(crt.Screen.WaitForString('#', 3) == True):
            crt.Screen.Send(command + "\n")
        elif(crt.Screen.WaitForString("word:") == True):
            crt.Screen.Send(second_password)
        else:
            crt.Dialog.MessageBox("execute command error")

        while(crt.Screen.WaitForString("More ----", 3) == True):
            crt.Screen.Send(" ")
        else:
            crt.Screen.Send("\n")
            crt.Screen.Send("\n")


class Loadblance(network_device):
    def __init__(self,host):
        self.host = host
        self.ssh_protocol = "SSH2"
        self.su_command = "enable"
        self.command_list = ["enable", "show interface brief", "show cpu","show memory", "show slb virtual-server", "show ha"]


class Switch(network_device):
    def __init__(self,host):
        self.host = host
        self.su_command = "super"
        self.command_list = ["super","display interface brief", "display cpu","display memory", "display vrrp"]


class Fireware(network_device):
    def __init__(self,host):
        self.host = host
        self.isPass2 = False
        self.su_command = "super"
        self.command_lifst = ["super", "display interface brief", "display cpu","display memory", "display vrrp", "display ip route", "display arp all", "display ospf brief"]


class Inner_fw(network_device):
    def __init__(self,host):
        self.host = host
        self.su_command = "super"
        self.command_list = ["super", "display interface brief", "display cpu","display memory", "display vrrp", "display ip route", "display arp all", "display ospf brief"]

fw_list = ["172.16.4.139", "172.16.4.140"]
inner_fw_list = ["172.16.4.135", "172.16.4.136"]
switch_list = ["172.16.4.133", "172.16.4.134", "172.16.4.137", "172.16.4.138", "172.16.4.133", "172.16.4.147", "172.16.4.148", "172.16.4.151", "172.16.4.152", "172.16.4.153", "172.16.4.154","172.16.4.141", "172.16.4.142", "172.16.4.129", "172.16.4.130", "172.16.4.145", "172.16.4.146"]
loadblance_list = ["172.16.4.131", "172.16.4.132", "172.16.4.149", "172.16.4.150"]

    
        
for list in list_list:
    c_name = list.rstrip("_list")
    for host in list:
        ip = c_name(host)
        connect(ip)
        for command in ip.command_list:
            execute_command(command)

