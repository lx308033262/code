#!/bin/bash
nohup masterha_manager --conf=/etc/mha_chukou.conf --ignore_last_failover > /tmp/mha_manager_chukou.log  < /dev/null 2>&1 &
