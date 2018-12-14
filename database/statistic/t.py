#!/usr/bin/env python
# -*- coding: utf-8 -*-
 

import MySQLdb
ip='192.168.199.17'
port=7000
user='root'
password='secret'
def e_conn():
    #global conn
    conn=MySQLdb.connect(host=ip,port=int(port),user=user,passwd=password,charset='utf8',connect_timeout=10)
    return conn

conn=e_conn()
cursor=conn.cursor()
cursor.execute("show databases;")
result=cursor.fetchall()
print result
cursor.close()
conn.close()
