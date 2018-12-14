#!/bin/bash

t_dir="/usr/local/"


echo -e "16k\n32k\n64k"|while read block_size
do
    echo "#############${block_size}################"
    echo "写入测试"
    dd if=/dev/zero of=${t_dir}a.txt count=102400 bs=${block_size}
    echo "读入测试"
    dd if=${t_dir}a.txt of=/dev/null count=102400 bs=${block_size}
    echo "读写测试"
    dd if=${t_dir}a.txt of=a.txt2 count=102400 bs=${block_size}
    echo "写入测试(nocache)"
    dd if=/dev/zero of=${t_dir}a.txt count=102400 bs=${block_size} oflag=direct
    echo "读入测试(nocache)"
    dd if=${t_dir}a.txt of=/dev/null count=102400 bs=${block_size} iflag=direct
    echo "读写测试(nocache)"
    dd if=${t_dir}a.txt of=${t_dir}a.txt2 count=102400 bs=${block_size} iflag=direct oflag=direct
done


echo -e "16k\n32k\n64k\n128k\n256k\n512k\n1m"|while read block_size
do
    echo "#############${block_size}################"
    echo "顺序读iops"
    /tmp/fio-2.1.4/fio --filename=${t_dir}aa.txt -iodepth=64 -ioengine=libaio -direct=1 -rw=read -bs=${block_size} -size=2g -numjobs=4 -runtime=20 -group_reporting -name=test-write|grep iops
    echo "顺序写iops"
    /tmp/fio-2.1.4/fio --filename=${t_dir}aa.txt -iodepth=64 -ioengine=libaio -direct=1 -rw=write -bs=${block_size} -size=2g -numjobs=4 -runtime=20 -group_reporting -name=test-write|grep iops
    echo "随机读iops"
    /tmp/fio-2.1.4/fio --filename=${t_dir}aa.txt -iodepth=64 -ioengine=libaio -direct=1 -rw=randread -bs=${block_size} -size=2g -numjobs=4 -runtime=20 -group_reporting -name=test-write|grep iops
    echo "随机写iops"
    /tmp/fio-2.1.4/fio --filename=${t_dir}aa.txt -iodepth=64 -ioengine=libaio -direct=1 -rw=randwrite -bs=${block_size} -size=2g -numjobs=4 -runtime=20 -group_reporting -name=test-write|grep iops
done
