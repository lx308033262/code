#!/bin/bash

#
#
#
awk 'NR>1 {print $5}' corp/corp.txt |sort -n >my_corp_name.txt
awk 'NR>1 {print $5}' school/corp.txt |sort -n >my_school_name.txt
awk 'NR>1 {print $1}' 江苏省飞信企业版数据校园.txt |sort -n > school_name.txt
awk 'NR>1 {print $1}' 江苏省飞信企业版数据.txt |sort -n > corp_name.txt
> In_corp_not_in_school.txt
> In_school_not_in_corp.txt

echo "in our school but in common corp"
while read line
do
    grep '^'${line}'$' my_corp_name.txt > /dev/null
    if [ $? -ne 0 ];then  
        grep '^'${line}'$' my_school_name.txt > /dev/null && echo "$line" >> In_school_not_in_corp.txt
    fi
done<corp_name.txt 

echo "in our corp but in common school"
while read line
do
    grep '^'${line}'$' my_school_name.txt > /dev/null
    if [ $? -ne 0 ];then  
        grep '^'${line}'$' my_corp_name.txt > /dev/null && echo "$line" >> In_corp_not_in_school.txt
    fi
done<school_name.txt

while read line
do
    awk '$1 == '\"${line}\"''  江苏省飞信企业版数据.txt >> 江苏省飞信企业版数据校园.txt
    sed -i '/^'$line'\t/d' 江苏省飞信企业版数据.txt 
done<In_school_not_in_corp.txt

while read line
do
    awk '$1 == '\"${line}\"''  江苏省飞信企业版数据校园.txt  >> 江苏省飞信企业版数据.txt
    sed -i '/^'$line'\t/d' 江苏省飞信企业版数据校园.txt
done<In_corp_not_in_school.txt
