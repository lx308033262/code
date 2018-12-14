#!/usr/bin/env python
# -*- coding: utf-8 -*-
#Author ZhangYan

import paramiko
from log import logger_root,logger_console


class nginx():
    def __init__(self,ip_list,port,user,password,path,ser_port,conf_path,lb_docker_flag):
        self.ip_list = ip_list
        self.port = port
        self.user = user
        self.pasword =password
        self.path = path
        self.conf_path = conf_path
        self.ser_port = ser_port
        self.lb_docker_flag = lb_docker_flag


    def run_command(self,cmd,ip):
        client=paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.load_system_host_keys()
        client.connect(hostname=ip,port=self.port,username=self.user,password=self.pasword)
        stdin,stdout,stderr = client.exec_command(cmd)
        stdin.write("%s\n" % (self.pasword))  #这两行是执行sudo命令要求输入密码时需要的
        stdin.flush()                         #执行普通命令的话不需要这两行
        stderr.read()
        if stdout == "stdout":
            logger_root.info(stdout.read())
        else:
            return stdout.read()
        client.close()


    def add(self,mod_ip):
        for ip in self.ip_list:
            nginx_path=self.path
            nginx_conf_path=self.conf_path
            cmd = "grep 'server %s:%s' %s/nginx.conf" % (mod_ip,self.ser_port,nginx_conf_path)
            out = self.run_command(cmd,ip)
            if out != '':
                cmd = "grep 'server %s:%s' %s/nginx.conf | grep '#' "  % (mod_ip, self.ser_port, nginx_conf_path)
                out = self.run_command(cmd, ip)
                if out == '': #如果没有注释的话就加注释
                    logger_root.info("[%s] add #" % mod_ip)
                    logger_console.info("[%s] add #" % mod_ip)
                    cmd = "sudo sed -i 's/server %s:%s/#server %s:%s/' %s/nginx.conf" % (mod_ip,self.ser_port,mod_ip,self.ser_port,nginx_conf_path)
                    self.run_command(cmd,ip)
                    if self.lb_docker_flag == 0:
                        cmd = "sudo  %s/nginx -s reload" % (self.path)
                        self.run_command(cmd,ip)
                    else:
                        cmd = "sudo docker exec -i lb %s/nginx -s reload" % (self.path)
                        self.run_command(cmd,ip)
                    logger_root.info("[%s] add sucessful!" % mod_ip)
                    logger_console.info("[%s] add sucessful!" % mod_ip)


    def dec(self,mod_ip):
        for ip in self.ip_list:
            nginx_path=self.path
            nginx_conf_path=self.conf_path
            cmd = "grep 'server %s:%s' %s/nginx.conf" % (mod_ip,self.ser_port,nginx_conf_path)
            out = self.run_command(cmd,ip)
            if out != '':
                logger_root.info("[%s] dec #" % mod_ip)
                logger_console.info("[%s] dec #" % mod_ip)
                cmd = "sudo grep 'server %s:%s' %s/nginx.conf | grep '#' " % (mod_ip,self.ser_port,nginx_conf_path)
                out = self.run_command(cmd,ip)
                if out != '':  #如果有注释的话就去掉注释
                    cmd = "sudo sed -i 's/#server %s:%s/server %s:%s/' %s/nginx.conf" % (mod_ip,self.ser_port,mod_ip,self.ser_port,nginx_conf_path)
                    self.run_command(cmd,ip)
                    if self.lb_docker_flag == 0:
                        cmd = "sudo  %s/nginx -s reload" % (self.path)
                        self.run_command(cmd,ip)
                    else:
                        cmd = "sudo docker exec -i lb %s/nginx -s reload" % (self.path)
                        self.run_command(cmd,ip)
                    logger_root.info("[%s] dec sucessful!" % mod_ip)
                    logger_console.info("[%s] dec sucessful!" % mod_ip)


