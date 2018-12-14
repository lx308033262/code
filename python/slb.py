#/usr/bin/env python
#-*- coding:utf-8 -*-
#Authot:Zhang Yan

from aliyunsdkcore.client import AcsClient
from aliyunsdkslb.request.v20140515 import RemoveVServerGroupBackendServersRequest,AddVServerGroupBackendServersRequest,DescribeVServerGroupAttributeRequest
from aliyunsdkecs.request.v20140526 import DescribeInstancesRequest
import json
from log import logger_root,logger_console
import subprocess

vs_field='|'
client=AcsClient(
    "7l9qDRufMcgnRx7A",
    "eiwNqout4lDPhXqGMzOGqC5svnd3sk",
    "cn-beijing"
)

def get_ecs_id(dec_ip):
    cmd = 'grep -w %s /etc/hosts' % dec_ip
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    dec_ip = p.stdout.read().strip().split()[0]
    request=DescribeInstancesRequest.DescribeInstancesRequest()
    InnerIpAddresses=[dec_ip]
    request.set_InnerIpAddresses(InnerIpAddresses)
    res = client.do_action_with_exception(request)
    res = json.loads(res)
    ecs_id=res['Instances']['Instance'][0]['InstanceId']
    return ecs_id

def get_backendservers(VServerGroupId):
    request = DescribeVServerGroupAttributeRequest.DescribeVServerGroupAttributeRequest()
    request.set_VServerGroupId(VServerGroupId)
    res = client.do_action_with_exception(request)
    res = json.loads(res)
    temp = res["BackendServers"]["BackendServer"]
    BackendServers=[]
    aa={}
    for i in temp:
        aa['ServerId']=str(i['ServerId'])
        aa['Port']=i['Port']
        aa['Weight']=i['Weight']
        BackendServers.append(aa)
    return BackendServers

def common(request,BackendServers):
    request.set_BackendServers(BackendServers)
    res = client.do_action_with_exception(request)
    return res

def add_slb(VServerGroupId,dec_ip,port):
    #if vs_field in VServerGroupId:
    #vs_list=VServerGroupId.split(vs_field)
    # 删除节点的话:BackendServers要删除的节点
    ecs_id=get_ecs_id(dec_ip)
    BackendServers = [
        {'ServerId': str(ecs_id), 'Port': port},
    ]
    for vs in VServerGroupId.split(vs_field):
        #删除节点,加注释
        request=RemoveVServerGroupBackendServersRequest.RemoveVServerGroupBackendServersRequest()
        request.set_VServerGroupId(vs)
        res=common(request,BackendServers)
        logger_console.info("slb加注释")
        logger_root.info("slb加注释")
        logger_root.info(res)
    return res

def dec_slb(VServerGroupId,dec_ip,port,weight=100):
    #添加节点的话:BackendServers要所有节点
    # BackendServers = [
    #     {'ServerId': 'i-2zeb3hjhdcuoqikqrjzu', 'Port': '80'},
    #     {'ServerId': 'i-2ze0hm1pb2afhex6htds', 'Port': '80'}
    # ]
    ecs_id = get_ecs_id(dec_ip)
    add_ser={'ServerId': str(ecs_id), 'Port': port, 'Weight': weight}
    for vs in VServerGroupId.split(vs_field):
        #添加节点，解注释
        request=AddVServerGroupBackendServersRequest.AddVServerGroupBackendServersRequest()
        request.set_VServerGroupId(vs)
        BackendServers = get_backendservers(vs)
        BackendServers.append(add_ser)
        res=common(request, BackendServers)
        logger_console.info("slb解注释")
        logger_root.info("slb解注释")
        logger_root.info(res)
    return res



