#!/bin/bash
conf_file='/home/cmcc/db-server'
declare -a instance_arry=($(awk '{print $1}' $conf_file|paste -s))

print_any()
{
	condition=$1
	result=$2
	awk "{print $
}

detect_by_instance()
{
	instance_name=$1
	if [[ $instance_name =~ "master" ]];then
		host=
