#!/bin/bash 
#host='192.168.0.136'
#port="8400"
#my='mysql -umyadmin -punknown'
#mytool="$my -P$port -h${host}"
month_keep_180_list="FACT_E_ACTIVITYUSER_YYYYMM FACT_E_ACTUSERSUM_YYYYMM FACT_E_ADMIN_LOGINFO_YYYYMM FACT_E_CLIENT_ACTION_YYYYMM FACT_E_CLIENT_ERR_LOG_YYYYMM FACT_E_CLIENT_OPER_LOG_YYYYMM FACT_E_CORP_DAILY_RPT_YYYYMM FACT_E_CORP_MONTHLY_RPT_YYYYMM FACT_E_EVOTE_YYYYMM FACT_E_GROUP_MSG_LOG_YYYYMM FACT_E_GROUP_TICKET_YYYYMM FACT_E_MO_TICKET_YYYYMM FACT_E_MT_TICKET_YYYYMM FACT_E_ONLINE_RPT_YYYYMM FACT_E_PLUGIN_OPER_LOG_YYYYMM FACT_E_PUBLISH_INFO_YYYYMM FACT_E_SYS_MESSAGE_YYYYMM FACT_E_USER_RPT_YYYYMM FACT_E_USERINFOSUM_YYYYMM osp_msg_system_history osp_systemnote_history imop_operlog imop_login_logout_history"
day_keep_180_list="navi_client_action_history FACT_E_ADMIN_INFO_YYYYMM FACT_E_CORP_INFO_YYYYMM FACT_E_USER_INFO_YYYYMM ioss_cdr_group ioss_cdr_presence ioss_cdr_sip_mo ioss_cdr_sip_mt ioss_clientlog_content ioss_st_clienterrlog ioss_clienterrlog"
field_keep_180_list="css_warning css_equip_warn"
field_keep_90_list="css_equip_sys_param_count css_service_open_count css_system_capacity_count osp_statistic_history"
field_keep_3_list="css_equip_sys_param css_equip_sys_param_history  css_equip_sys_param_history_sub css_equip_sys_param_sub"

DAY=`date +%Y%m%d`

#上地
my="/usr/bin/mysql -umyadmin -pmysupp@xmcx"
port="3306"

#外测
#find_database_name()
#{
#        local table=$1
#        all_database=`$mytool -N -e "show databases;"|grep -Ev 'mysql|information_schema'`
#        for database in $all_database
#        do
#            $mytool -N -e "show tables from $database"|grep "${table}$" > /dev/null 2>&1
#            if [ $? -eq 0 ];then
#              db_name=$database
#              break
#            else
#              continue
#            fi
#        done
#}

#上地
find_database_name()
{
    conf_file="/home/cmcc/db-server"
    local table=$1
    all_database=`awk '{print $NF}' $conf_file |tr '\n,' ' '`
    for database in $all_database
    do
        host=`grep "$database" $conf_file | sort -n -k3|awk '{print $3}'|tail -1`
        $my -h$host -N -e "show tables from $database"|grep "${table}$" > /dev/null 2>&1
        if [ $? -eq 0 ];then
           db_name=$database
            mytool="$my -h$host -P$port"
            break
        else
            continue
        fi
    done
}

delete_by_date()
{
  find_database_name $table
  local day=$1
  if [ -n "$monthflag" ];then
      expire_day=`$mytool -N -e 'select date_format(subdate('$DAY','$day'),"%Y%m");'`
  else
      expire_day=`$mytool -N -e 'select subdate('$DAY','$day')+0;'`
  fi
  if [ "$db_name" == "imsdb" ];then
      D_list=`$mytool -N -e "show tables from ${db_name} like '${table%_*}%'"|awk -v a=$expire_day -F'_' '{if($NF<a)print}'`
  else
      D_list=`$mytool -N -e "show tables from ${db_name} like '${table}%'"|awk -v a=$expire_day -F'_' '{if($NF<a)print}'`
  fi
  for table in $D_list
  do
	echo "drop table ${db_name}.${table}"
    $mytool -e "drop table ${db_name}.${table};"
  done
}

delete_by_field()
{
  find_database_name $table
  local field_name=$1
  local day=$2
  datestamp=`$mytool -N -e 'select subdate('$DAY','$day');'`
  echo   "delete from ${db_name}.${table} where ${field_name} < '"$datestamp"'"
  $mytool -N -e "delete from ${db_name}.${table} where ${field_name} < '"$datestamp"'"
}

for table in $day_keep_180_list
do
    delete_by_date 180 $table
done

for table in $month_keep_180_list
do
   monthflag=1
   delete_by_date 180 $table
done

for table in $field_keep_180_list
do
    if [ "$table" == "css_warning" ];then
        delete_by_field warning_time 180
    elif [ "$table" == "css_equip_warn" ];then
        delete_by_field warn_date 180
    else
        echo "wrong table"
        exit
    fi
done

for table in $field_keep_90_list
do
    if [ "$table" == "css_equip_sys_param_count" ];then
        delete_by_field update_date 90
    else
        delete_by_field logtime 90    
    fi

done

for table in $field_keep_3_list
do
    delete_by_field update_date 3
done
