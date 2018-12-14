#!/bin/bash
nohup masterha_manager --conf=/etc/mha_im.conf --ignore_last_failover > /tmp/mha_manager_im.log  < /dev/null 2>&1 &
