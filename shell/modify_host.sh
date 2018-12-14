#!/bin/bash

conf_file="cluster_ip.conf"

bond_file="/etc/sysconfig/network-scripts/ifcfg-bond0" 
hostname_file="/etc/sysconfig/network" 
cluster_file="/etc/cluster/cluster.conf" 
host_file="/etc/hosts" 

cluster_name=$1
host_flag=$2


print_usage()
{
    echo "--------Usage--------------------"
    echo "$0 cluster_name host_flag"
    echo "cluster_name must be navi(core/boss/sa/mng)"
    echo "host_flag must be 01/02"
    echo "--------Usage--------------------"
}

if [ -z "$cluster_name" -o -z "$host_flag" ];then
    print_usage
    exit 1
fi

IP=`awk '/'$cluster_name'/ {print $2}' $conf_file |grep "$host_flag"`
NEW_IP=`awk '/'$cluster_name'/ {print $3}' $conf_file |grep "$host_flag"`
VIP=`awk '/'$cluster_name'/ {print $4}' $conf_file |grep "$host_flag"`
OLD_VIP=`awk '/'$cluster_name'/ {print $5}' $conf_file |grep "$host_flag"`
HOST=`awk '/'$cluster_name'/ {print $6}' $conf_file |grep "$host_flag"`
NEW_HOST=`awk '/'$cluster_name'/ {print $7}' $conf_file |grep "$host_flag"`
if [ -z "$IP" -o -z "$NEW_IP" -o -z "$VIP" -o -z "$OLD_VIP" -o -z "$HOST" -o -z "$NEW_HOST"  ];then
    print_usage
    exit 1
fi

#sed -i 's/'$NEW_HOST'/'$HOST'/g' $host_file
sed -i 's/-new//g' $host_file
sed -i 's/IPADDR=.*/IPADDR='$IP'/g' $bond_file
sed -i 's/HOSTNAME=.*/HOSTNAME='$HOST'/g' $hostname_file
sed -i 's/'$NEW_HOST'/'$HOST'/g' $cluster_file
sed -i 's/'$OLD_VIP'/'$VIP'/g' $cluster_file
