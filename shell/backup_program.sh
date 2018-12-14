#!/bin/bash
backup_dir=/data/backup
project_dir=/data/webapps
day=`date +%F`
[ -d "$backup_dir" ] || mkdir -p $backup_dir
cd $backup_dir
#同步程序目录的备份目录，不同步打包文件/svn文件/日志文件
rsync -avz --exclude=*.tar.gz --exclude=.subversion/ --exclude=logs/ --exclude=log/ $project_dir ./
#打包备份文件并且删除备份文件夹
tar czf bak_${day}.tar.gz ${project_dir##*/} && rm -rf ${project_dir##*/}
#删除90天以前的备份文件
find ./ -mtime +90 -name "*.tar.gz" -exec rm -rf {} \;
