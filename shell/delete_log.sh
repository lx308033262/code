#!/bin/bash

log_path='/home/kuaikuai/apache-tomcat-7.0.62/logs'
log_keep_days=120

for path in $log_path
do
#    [ -d "$path" ] && cd "$log_path"
    if [ -d "$path" ];then
        cd "$log_path"
        find ./ -name "*.log*" -mtime +${log_keep_days} -exec rm -f {} \;
    fi
done
