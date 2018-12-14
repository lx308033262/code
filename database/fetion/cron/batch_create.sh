#!/bin/bash
#外侧
#host='192.168.0.136'
#port="8400"
#my='mysql -umyadmin -punknown'
#mytool="$my -P$port -h${host}"
#month_list='imop_login_logout_history imop_operlog osp_msg_system_history osp_systemnote_history FACT_E_ACTIVITYUSER_YYYYMM FACT_E_ACTUSERSUM_YYYYMM FACT_E_ADMIN_LOGINFO_YYYYMM FACT_E_CLIENT_ACTION_YYYYMM FACT_E_CLIENT_ERR_LOG_YYYYMM FACT_E_CLIENT_OPER_LOG_YYYYMM FACT_E_CORP_DAILY_RPT_YYYYMM FACT_E_CORP_MONTHLY_RPT_YYYYMM FACT_E_EVOTE_YYYYMM FACT_E_GROUP_MSG_LOG_YYYYMM FACT_E_ONLINE_RPT_YYYYMM FACT_E_PLUGIN_OPER_LOG_YYYYMM FACT_E_PUBLISH_INFO_YYYYMM FACT_E_SYS_MESSAGE_YYYYMM FACT_E_USER_RPT_YYYYMM FACT_E_USERINFOSUM_YYYYMM' 


#上地
my="/usr/bin/mysql -umyadmin -pmysupp@xmcx"
port="3306"
DAY=`date +%Y%m%d`

month_list='imop_login_logout_history imop_operlog osp_msg_system_history osp_systemnote_history FACT_E_ACTIVITYUSER_YYYYMM FACT_E_ACTUSERSUM_YYYYMM FACT_E_ADMIN_LOGINFO_YYYYMM FACT_E_CLIENT_ACTION_YYYYMM FACT_E_CLIENT_ERR_LOG_YYYYMM FACT_E_CLIENT_OPER_LOG_YYYYMM FACT_E_CORP_DAILY_RPT_YYYYMM FACT_E_CORP_MONTHLY_RPT_YYYYMM FACT_E_EVOTE_YYYYMM FACT_E_GROUP_MSG_LOG_YYYYMM FACT_E_GROUP_TICKET_YYYYMM FACT_E_MO_TICKET_YYYYMM FACT_E_MT_TICKET_YYYYMM FACT_E_ONLINE_RPT_YYYYMM FACT_E_PLUGIN_OPER_LOG_YYYYMM FACT_E_PUBLISH_INFO_YYYYMM FACT_E_SYS_MESSAGE_YYYYMM FACT_E_USER_RPT_YYYYMM FACT_E_USERINFOSUM_YYYYMM ics_details ics_operate osp_email_history'

day_list='navi_client_action_history navi_client_oper_history ioss_cdr_group ioss_cdr_presence ioss_cdr_sip_mo ioss_cdr_sip_mt ioss_clienterrlog ioss_clientlog_content ioss_st_clienterrlog FACT_E_ADMIN_INFO_YYYYMM FACT_E_CORP_INFO_YYYYMM FACT_E_USER_INFO_YYYYMM'


#经分日表
#DAY=20121230
#host="192.168.2.18"
#day_list='FACT_IMS_SRV_ADMIN_OPER_YYYYMMDD FACT_IMS_SRV_AUTO_REPLAY_YYYYMMDD FACT_IMS_SRV_CLIENT_ACTION_YYYYMMDD FACT_IMS_SRV_CLIENT_OPER_YYYYMMDD FACT_IMS_SRV_CORP_INFO_YYYYMMDD FACT_IMS_SRV_CORP_URI_YYYYMMDD FACT_IMS_SRV_EVOTE_YYYYMMDD FACT_IMS_SRV_MMS_YYYYMMDD FACT_IMS_SRV_SHARE_INFO_YYYYMMDD FACT_IMS_SRV_SMS_REPLAY_YYYYMMDD FACT_IMS_SRV_SMS_YYYYMMDD FACT_IMS_SRV_USER_INFO_YYYYMMDD FACT_E_CORP_INFO_YYYYMMDD FACT_E_ADMIN_INFO_YYYYMMDD FACT_E_USER_INFO_YYYYMMDD'

#month_list='FACT_E_ACTIVITYUSER_YYYYMM FACT_E_ACTUSERSUM_YYYYMM FACT_E_ADMIN_LOGINFO_YYYYMM FACT_E_CLIENT_ACTION_YYYYMM FACT_E_CLIENT_ERR_LOG_YYYYMM FACT_E_CLIENT_OPER_LOG_YYYYMM FACT_E_CORP_DAILY_RPT_YYYYMM FACT_E_CORP_MONTHLY_RPT_YYYYMM FACT_E_CORP_RPT_YYYYMM FACT_E_EVOTE_YYYYMM FACT_E_GROUP_MSG_LOG_YYYYMM FACT_E_GROUP_TICKET_YYYYMM FACT_E_MO_TICKET_YYYYMM FACT_E_MT_TICKET_YYYYMM FACT_E_ONLINE_RPT_YYYYMM FACT_E_PLUGIN_OPER_LOG_YYYYMM FACT_E_PUBLISH_INFO_YYYYMM FACT_E_SYS_MESSAGE_YYYYMM FACT_E_USERINFOSUM_YYYYMM FACT_IMS_SRV_E_CORP_DAILY_RPT_YYYYMM FACT_IMS_SRV_E_USER_RPT_YYYYMM RPT_SRV_ADMIN_INFO_YYYYMM RPT_SRV_AUDIO_INFO_YYYYMM RPT_SRV_AUDIO_VIDEO_INFO_YYYYMM RPT_SRV_CLIENT_BASE_INFO_YYYYMM RPT_SRV_CLIENT_BASE_OPER_INFO_YYYYMM RPT_SRV_CLIENT_CONTACTS_INFO_YYYYMM RPT_SRV_CLIENT_INFO_YYYYMM RPT_SRV_CLIENT_MMS_INFO_YYYYMM RPT_SRV_CORP_CENTREX_INFO_YYYYMM RPT_SRV_CORP_DEV_YYYYMM RPT_SRV_CORP_INFO_YYYYMM RPT_SRV_CORP_SERVER_YYYYMM RPT_SRV_EVOTE_INFO_YYYYMM RPT_SRV_GROUP_INFO_YYYYMM RPT_SRV_SHARE_INFO_YYYYMM RPT_SRV_SMS_MMS_YYYYMM RPT_SRV_USER_DEV_YYYYMM RPT_SRV_VIDEO_INFO_YYYYMM FACT_E_USER_RPT_YYYYMM'

#外测
#find_database_name()
#{
#        local table=$1
#	all_database=`$mytool -N -e "show databases;"|grep -Ev 'mysql|information_schema'`
#	for database in $all_database
#	do
#            $mytool -N -e "show tables from $database"|grep "${table_name}$" > /dev/null 2>&1
#            if [ $? -eq 0 ];then
#	      db_name=$database
#              break
#            else
#              continue
#            fi
#	done
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

create_daily_table()
{
for ((i=1;i<=32;i++))
do
#db_name=imsdb_new
  day=`$mytool -N -e 'select adddate('$DAY','$i') + 0;'`
  if [ "$database" == "imsdb" -o "$db_name" == "imsdb_new" ];then
    echo "create table if not EXISTS  ${db_name}.${table_name%_*}_${day} like ${db_name}.${table_name}"
    $mytool -N -e "create table if not EXISTS  ${db_name}.${table_name%_*}_${day} like ${db_name}.${table_name}"
	$mytool -N -e "desc ${db_name}.${table_name%_*}_${day}" |awk '{print $1,$2}' > a.tmp
	$mytool -N -e "desc ${db_name}.${table_name}" |awk '{print $1,$2}' > b.tmp
	diff a.tmp b.tmp || echo "${db_name}.${table_name%_*}_${day} ${db_name}.${table_name} different" >> diff.log
  else
    echo  "create table if not EXISTS  ${db_name}.${table_name}_${day} like ${db_name}.${table_name}"  
    $mytool -N -e "create table if not EXISTS  ${db_name}.${table_name}_${day} like ${db_name}.${table_name}"
	$mytool -N -e "desc ${db_name}.${table_name}_${day}" |awk '{print $1,$2}' > a.tmp
	$mytool -N -e "desc ${db_name}.${table_name}" |awk '{print $1,$2}' > b.tmp
	diff a.tmp b.tmp || echo "${db_name}.${table_name}_${day} ${db_name}.${table_name} different" >> diff.log
  fi
done
}

create_mothly_table()
{
#db_name=imsdb_new
  month=`$mytool -N -e 'select date_format(adddate('$DAY',20),"%Y%m");'`
  if [ "$db_name" == "imsdb" -o "$db_name" == "imsdb_new" ];then
    echo "create table if not EXISTS ${db_name}.${table_name%_*}_${month} like ${db_name}.${table_name}"  
    $mytool -N -e "create table if not EXISTS ${db_name}.${table_name%_*}_${month} like ${db_name}.${table_name}"
	$mytool -N -e "desc ${db_name}.${table_name%_*}_${month}" |awk '{print $1,$2}' > a.tmp
	$mytool -N -e "desc ${db_name}.${table_name}" |awk '{print $1,$2}' > b.tmp
	diff a.tmp b.tmp || echo "${db_name}.${table_name%_*}_${month} ${db_name}.${table_name} different" >> diff.log
  else
    echo "create table if not EXISTS ${db_name}.${table_name}_${month} like ${db_name}.${table_name}"
    $mytool -N -e "create table if not EXISTS ${db_name}.${table_name}_${month} like ${db_name}.${table_name}"
	$mytool -N -e "desc ${db_name}.${table_name}_${month}" |awk '{print $1,$2}' > a.tmp
	$mytool -N -e "desc ${db_name}.${table_name}" |awk '{print $1,$2}' > b.tmp
	diff a.tmp b.tmp ||  echo "${db_name}.${table_name}_${month} ${db_name}.${table_name} different" >> diff.log
  fi
}

for table_name in $day_list
do
    find_database_name $table_name
    create_daily_table
done

for table_name in $month_list
do
     find_database_name $table_name
     create_mothly_table
done
rm -f a.tmp b.tmp
