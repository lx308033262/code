#!/bin/bash
gdb_tool='mysql -h172.21.1.77 -ujabber -pzhoudaidba'
pdb_tool='mysql -h172.21.1.72 -ujabber -pzhoudaidba'
log_flag=0
corp_file='corp.txt'
#super_admin_file='superadmin.txt'
#admin_file='admin.txt'
#user_file='user.txt'
#department_file='department.txt'

print_log()
{
   if [ $log_flag -eq 1 ];then
	echo $1
   fi
}

print_log  "start truncate file"
for file in $corp_file 
#$super_admin_file $admin_file $user_file $department_file
do
    > $file
done

print_log "get corporations's information"
#while read line
#do
    $gdb_tool -N -e " select a.eid,a.corp_code,a.contact,a.contact_mp,a.corp_name,b.city_name from gweb_db.gweb_corp_info a left join gcfg_db.gcfg_city b on a.city_code = b.city_code where a.province_code = 'js'  and a.order_flag = 1 and  a.calling_code = 2003;" > $corp_file
    #$gdb_tool -N -e " select a.eid,a.corp_code,a.contact,a.contact_mp,a.corp_name,b.city_name from gweb_db.gweb_corp_info a left join gcfg_db.gcfg_city b on a.city_code = b.city_code where a.province_code = 'js'  and a.order_flag = 1 and  a.calling_code != 2003;" > $corp_file
    #$gdb_tool -N -e "select a.eid,a.corp_code,a.contact,a.contact_mp,a.corp_name,b.city_name from gweb_db.gweb_corp_info a left join gcfg_db.gcfg_city b on a.city_code = b.city_code where corp_name like '${line}%'" >> $corp_file
#done<a.txt

print_log "create temp department table"
$pdb_tool -e "DROP TABLE IF EXISTS test.t;"
$pdb_tool -e "CREATE TABLE IF NOT EXISTS test.t (eid int(10) default NULL,  deptid int(10) default NULL,  parentid int(10) default NULL,  deptname varchar(256) default NULL,  depth int(10) default NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;"

#get corporations's administrator information 
awk ' {print $1,$5,$6}' $corp_file|while read line corp city
do
    mkdir -p ${corp}
    mkdir -p ${city}
    suffix=${line:5:1}
    #$gdb_tool -N -e "select eid,corp_code,admin_name,admin_tel from gweb_db.gweb_corp_admin where eid = ${line} and level = 0" >> $super_admin_file
    #$gdb_tool -N -e "select eid,corp_code,admin_name,admin_tel from gweb_db.gweb_corp_admin where eid = ${line}" >> $admin_file
    $gdb_tool -N -e " select a.eid,a.corp_code,a.contact,a.contact_mp,a.corp_name,b.city_name from gweb_db.gweb_corp_info a left join gcfg_db.gcfg_city b on a.city_code = b.city_code where a.eid = ${line};" > ${corp}_corp_info.txt
    $gdb_tool -N -e "select eid,corp_code,admin_name,admin_tel from gweb_db.gweb_corp_admin where eid = ${line} and level = 0;" > ${corp}_superadmin.txt
    $gdb_tool -N -e "select eid,corp_code,admin_name,admin_tel from gweb_db.gweb_corp_admin where eid = ${line};" > ${corp}_admin.txt
    print_log "$line"


    #insert department data
    print_log "start insert ${corp} departments"
    $pdb_tool -e "truncate table test.t;"
    $pdb_tool -e "insert into test.t select eid,deptid,parent_id,dept_name,depth from pcore_db.pcore_corp_departments where eid = ${line};"

    #update departments information
    print_log "start update  ${corp} departments"
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 2;"
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 3;" 
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 4;" 
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 5;" 
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 6;" 
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 7;" 
    $pdb_tool -e "update test.t a inner join test.t b on a.parentid = b.deptid set a.deptname = concat(b.deptname,'/',a.deptname) where a.depth = 8;" 
    
    #get department info
    print_log "get ${corp} departments"
    #$pdb_tool -N -e "select eid,deptname from test.t" >> $department_file
    $pdb_tool -N -e "select eid,deptname from test.t;" >> ${corp}_department.txt

    #get user info
    print_log "get user info"
    #$pdb_tool -N -e "select a.eid,b.mp,b.full_name,b.email,c.deptname from pcore_db.pcore_corp_employee_0${suffix} a inner join pcore_db.pcore_vcard_0${suffix} b inner join test.t c on a.userid = b.userid  and a.deptid = c.deptid where a.eid =${line}  and b.mp is not null and b.mp != 0 and  operate_type != 3 ;" >> $user_file
    $pdb_tool -N -e "select a.eid,b.mp,b.full_name,b.email,c.deptname from pcore_db.pcore_corp_employee_0${suffix} a inner join pcore_db.pcore_vcard_0${suffix} b inner join test.t c on a.userid = b.userid  and a.deptid = c.deptid where a.eid =${line}  and b.mp is not null and b.mp != 0 and  operate_type != 3 ;" >> ${corp}_employees.txt
    sed -i "1i eid\tcorp_code\t超级管理员名称\t超级管理员电话" ${corp}_superadmin.txt
    sed -i "1i eid\tcorp_code\t管理员名称\t管理员电话" ${corp}_admin.txt
    sed -i "1i eid\t手机号\t员工姓名\t员工邮箱\t员工部门" ${corp}_employees.txt
    sed -i "1i eid\t部门名称" ${corp}_department.txt
    sed -i "1i eid\tcorp_code\t联系人\t联系电话\t公司名称\t城市" ${corp}_corp_info.txt
    mv ${corp}_superadmin.txt ${corp}_admin.txt ${corp}_employees.txt ${corp}_department.txt ${corp}_corp_info.txt ${corp}
    mv ${corp} ${city}
done


