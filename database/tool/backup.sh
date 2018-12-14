#!/bin/bash

#!/bin/bash
DATABASES=(search)
START_TIME=`date +%s`
#DATETIME=`date +%F" "%H:%M:%S`
DATE=`date +%Y%m%d%H`
BACKUP_DIR="/opt/DB_backup/mydump$DATE"
DB_HOST="localhost"
DB_USER="root"
DB_PASSWORD="XchxHo7smfd2wF"
MYSQL=/usr/local/mysql3306/bin/mysql
MYSQLDUMP=/usr/local/mysql3306/bin/mysqldump

##判断备份目录是否存在，否则创建
if [ -d $BACKUP_DIR ];then
    echo "The dir is exist!"
else
    mkdir -p $BACKUP_DIR
fi

##备份指定数据库并压缩
echo  " $(date +%F" "%H:%M:%S) Begin to backup databases"
for dbname in ${DATABASES[@]}
do
      [ -d "$BACKUP_DIR/$dbname" ] || mkdir -p ${BACKUP_DIR}/$dbname
      echo "$(date +%F" "%H:%M:%S) Begin to backup $dbname"
      for tb in `$MYSQL -N -u$DB_USER -p$DB_PASSWORD -e "show tables from $dbname"`
      do
      if $($MYSQLDUMP -u$DB_USER -p$DB_PASSWORD --default-character-set=utf8mb4 -R --trigger --single-transaction $dbname $tb > ${BACKUP_DIR}/$dbname/$tb$DATE.sql);then
        echo "$(date +%F" "%H:%M:%S) $tb backup successfull!"
      else
        echo "$(date +%F" "%H:%M:%S) $tb backup is Failed!!!!!!!!!!!!"
      fi
      done
      echo "$(date +%F" "%H:%M:%S) Finished!"
done
echo "$(date +%F" "%H:%M:%S) Begin to compress!!"
tar -czf ${BACKUP_DIR}.tar.gz ${BACKUP_DIR}
rm -rf ${BACKUP_DIR}

####删除60天以前的备份
cd /opt/DB_backup
find ./ -mtime +60 -exec rm  {} \;
STOP_TIME=`date +%s`
echo $(($STOP_TIME-$START_TIME)) >> /tmp/backup.time

