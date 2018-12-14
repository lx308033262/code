#!/bin/bash

#author :zuoxingyu
#create_date:2014-05-28
#usage :./single_table_restore.sh back.sql DB1
#usage :./single_table_restore.sh back.sql DB1 T1

BACKUP_FILE=$1
DB_NAME=$2
TB_NAME=$3

#至少有2个参数,第一个参数是备份文件名称，第二个参数是库名称，第三个参数是表名称，第三个参数不存在时，恢复库
if [ "-$1" = "-" ];then
    echo "you must privide backup file."
    exit 0
fi

if [ "-$2" = "-" ];then
    echo "you must provide database name or table name."
    exit 0
fi

echo "restore DB_NAME:" $DB_NAME "restore TB_NAME:" $TB_NAME

echo "generate restore file start" `date "+%Y-%m-%d %H:%M:%S"`
if [ "-$3" != "-" ];then
    sed -n "/^-- Current Database: \`$DB_NAME\`/,/^-- Current Database:/p" $BACKUP_FILE|sed -n "/^-- Table structure for table \`$TB_NAME\`/,/^UNLOCK TABLES/p" >restore.sql
else
    sed -n "/^-- Current Database: \`$DB_NAME\`/,/^-- Current Database:/p" $BACKUP_FILE>restore.sql
fi
echo "generate restore file end" `date "+%Y-%m-%d %H:%M:%S"`
echo "filename:./restore.sql"

