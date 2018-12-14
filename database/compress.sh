#!/bin/bash
PATH=$PATH:/usr/local/services/mysql3306/bin/

data_dir="/data"

cd $data_dir
#find ./ -path "./mysql" -prune -o  -name "*.MYD" -exec ls -l {} \;
for file in `find ./ -path "./mysql" -prune -o  -name "*.MYI" -size +1M -mtime +30 -print;`
do
    myisampack $file
    myisamchk -rq $file
done
