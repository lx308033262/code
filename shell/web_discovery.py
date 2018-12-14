#!/usr/bin/env python
# -*- coding: utf-8 -*-
 
file="/etc/zabbix/script/api.txt"

import simplejson as json
import fileinput

url=[]
host=[]
ip=[]
str=""
url= "{\n" + "\t" + '"data":[' + "\n"
for line in fileinput.input(file):
    #print line,fileinput.filelineno()
    if fileinput.filelineno() % 3 == 1:
        #url += [{'{#URL}':line}]
        str+='\t\t{\n\t\t"{#URL}": "%s",\n' % line.strip("\n")
        #print str
    elif fileinput.filelineno() % 3 == 2:
        #url += [{'{#HOST}':line}]
        str+='\t\t"{#HOST}": "%s",\n' % line.strip("\n")
        #print str
    elif fileinput.filelineno() % 3 == 0:
        #url += [{'{#IP}':line}]
        str+='\t\t"{#KEYWORD}": "%s"\t\t\n},' % line.strip("\n")
        #print str
        url+=str
        str=""
    #print url,host,ip
    #print str
    continue

url=url.rstrip(",")
url+="\n\t]\n}"

print url

#print "url",url
#for u in url:
#    print u

#print json.dumps({"data":url},sort_keys=True,indent=4)
#print json.dumps({'url':url},sort_keys=True,indent=4,separators=(',',':'))


