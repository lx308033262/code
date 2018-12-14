#!/bin/bash

mytool="mysql -uroot -psecret -S /tmp/mysql3306.sock"
BINLOG_FILE=$1
db=$2
table_name=$3
LOG_FILE=redo.log
TMP_LOG_FILE=tmp_${LOG_FILE}

>${LOG_FILE}
>${TMP_LOG_FILE}

mysqlbinlog -vvv $BINLOG_FILE > ${LOG_FILE}

FIELD_COUNT=`$mytool -N -e "desc $db.$table_name"|wc -l`
GREP_COUNT=$((${FIELD_COUNT} + 1))

grep '###' ${LOG_FILE}|grep 'DELETE FROM '${db}'.'${table_name}'' -A ${GREP_COUNT} >${TMP_LOG_FILE}
sed -i 's/###//g' ${TMP_LOG_FILE}
sed -i 's/\*\//\*\/,/g' ${TMP_LOG_FILE}
sed -i '/@'${FIELD_COUNT}'/s/\*\/,/\*\/;/g' ${TMP_LOG_FILE}
sed -i 's/DELETE FROM/INSERT INTO/g' ${TMP_LOG_FILE}
sed -i 's/WHERE/SET/g' ${TMP_LOG_FILE}
sed -i '/@/s/=\(.*\) \//="\1" \//g' ${TMP_LOG_FILE}
sed -i '/at/d' ${TMP_LOG_FILE}
i=1
$mytool -N -e "desc $db.$table_name"|awk '{print$1}'|while read line
do
sed -i 's/@'$i'/'$line'/g' ${TMP_LOG_FILE}
let i++
done


