#!/bin/bash

GREEN="\033[32;49;1m"
RED="\033[31;49;1m"
ENDCOLOR="\033[39;49;0m"

TODAY=`date +%F`
FUNCTIONS="check_md5 backup uncompress update start stop check auto_update help continue exit"
SCRIPT_DIR="/home/cmcc/python/pushfile/"
JAVA_PATH="/home/cmcc/update/source/j2ee/"
JAVA_TEMPLATE_PATH="/home/cmcc/update/source/j2eemod/"
C_PATH="/home/cmcc/update/source/c/"
C_TEMPLATE_PATH="/home/cmcc/update/source/cmod/"
BACKUP_FILE_LIST="pzj2ee.txt pzpgm.txt config_module.txt config.txt"
BACKUP_DIR="/home/cmcc/update/source/backupmod/${TODAY}/"
BACKUP_TEMPLATE_DIR="/home/cmcc/update/source/backupmod/template/${TODAY}/"
CONFIG_BACKUP_DIR="${BACKUP_DIR}config/"
UPDATE_DIR="/home/cmcc/update/source/updatemod/${TODAY}/"
S_SVN_CONFIG_NAME=""
SVN_INFO_FILE=""
LOG_PATH=/tmp/auto_update.log
#3种日志级别 error、warn、info
LOG_LEVEL=error

#添加日志函数 
#usage:addlog log_level log_content
#exam:addlog info "begin backup"
add_log()
{
    #日志级别记录较高时会自动记录低级别的日志
    if [ ${LOG_LEVEL} == "info" ];then
        LOG_LEVEL="${LOG_LEVEL},warn,info"
    elif [ ${LOG_LEVEL} == "warn" ];then
        LOG_LEVEL="${LOG_LEVEL},error"
    fi
    if [[ "${LOG_LEVEL}" =~ "$1" ]];then
        echo `date "+%F %T"` >> ${LOG_PATH}
        echo -n "[$1]: " >> ${LOG_PATH}
        shift 1
        for par in $*
        do
            echo -n "$par" |tee ${LOG_PATH}
        done
        echo ""
    fi
}

#tar失败函数
tar_error()
{
    add_log error "tar file $_ faild"
    exit
}

#创建目录函数
create_dir()
{
    add_log info "${FUNCNAME} begin"
    for dir in $*
    do
        [ -d $dir ] || mkdir -p $dir
    done
    add_log info "${FUNCNAME} done"
}

#检测模块类型函数
detect_mod_type()
{
    add_log info "${FUNCNAME} begin"
    cd $SCRIPT_DIR
    mod_type=`awk -F'|' '$1=="'$mod_name'" {print $9}' config_module.txt|uniq`
    if [ "$mod_type" == "c" ];then
        config_file="pzpgm.txt"
		MOD_PATH=${C_PATH}
        MOD_TEMPLATE_PATH=${C_TEMPLATE_PATH}
    elif [ "$mod_type" == "java" ];then
        config_file="pzj2ee.txt"
		MOD_PATH=${JAVA_PATH}
        MOD_TEMPLATE_PATH=${JAVA_TEMPLATE_PATH}
    else
        add_log error "mod_type is error"
        exit
    fi
    add_log info "${FUNCNAME} done"
}

#比较日期的函数，如果有多个模块更新包,取日期最新的一个更新
compare_date()
{
    add_log info "${FUNCNAME} begin"
    for name in $1
    do
        datetmp=`echo $name|awk -F'[-.]' '{printf "%s-%s-%s %s:%s:%s",$2,$3,$4,$5,$6,$7}'`
        if [ $(date -d "$datetmp" +%s) -gt $max_date ];then
            max_date=$(date -d "datetmp" +%s)
            final_name=$name
        fi
    done
    add_log info "${FUNCNAME} done"
}

#修改名字的函数，将孙浩打包的外测包的名字更改为符合我们本地更新的模块名称
change_name()
{
    add_log info "${FUNCNAME} begin"
    cd ${UPDATE_DIR}
    tar xzf ${s_mod_name}.tar.gz
    mv ${s_mod_name} ${mod_name}
    tar -czf ${mod_name}.tar.gz ${mod_name} && rm -rf ${mod_name}||tar_error
    add_log info "${FUNCNAME} done"
}

#检测文件完整性的函数
check_md5()
{
    add_log info "${FUNCNAME} begin"
    md5check()
    {
    if [ -f $1.tar.gz ];then
        md5sum -c $1.md5
        if [ $? -eq 0 ];then
            add_log info "md5 check complete, file ok"
        else
             add_log error "check faild"
             exit
        fi
    else
        add_log error "file does not exist"
        exit
    fi
    }

    #检测是否有多个模块更新文件，如果有多个，取最新时间的更新包
    cd ${UPDATE_DIR}
    mod_name_prefix=`MOD2TAR ${mod_name}`
    tmp_mod_name=`ls ${mod_name_prefix}[-]*.tar.gz`
    count_mod_name=`ls ${mod_name_prefix}[-]*.ta.gz|wc -l`
    if [ ${count_mod_name} -gt 1 ];then
        compare_date $tmp_mod_name
        s_mod_name=$final_name
    else
        s_mod_name=${tmp_mod_name}
    fi

    #检测是否有多个SVN的更新配置文件，如果有多个，取最新时间的更新包
    tmp_svn_name=`ls ${S_SVN_CONFIG_NAME}[-]*.tar.gz`
    count_svn_name=`ls ${S_SVN_CONFIG_NAME}[-]*.ta.gz|wc -l`
    if [ ${count_svn_name} -gt 1 ];then
        compare_date $tmp_svn_name
        SVN_CONFIG_NAME=$final_name
    else
	    SVN_CONFIG_NAME=${tmp_svn_name}
    fi

    #检测模块更新文件的完整性并改名
    md5check {s_mod_name}
    change_name

    #检测svn推送配置文件的完整性
    md5check ${SVN_CONFIG_NAME}.md5
    add_log info "${FUNCNAME} done"
}

#解压函数
uncompress()
{
    add_log info "${FUNCNAME} begin"
    cd $UPDATE_DIR
    tar xzf ${mod_name}.tar.gz 
    tar xzf ${SVN_CONFIG_NAME}.tar.gz 
    add_log info "${FUNCNAME} done"
}

#备份函数 添加备份失败动作
backup()
{
    add_log info "${FUNCNAME} begin"
    cd $UPDATE_DIR
    BACKUP_FILE_NAME="${mod_name}-`date +%F-%T`.tar.gz"
    VERSION=`grep 'Revision' ${SVN_CONFIG_NAME}|awk '{print $2}'`
    create_dir ${BACKUP_DIR}${VERSION} ${BACKUP_TEMPLATE_DIR}${VERSION} ${CONFIG_BACKUP_DIR}${VERSION}
    mv ${SVN_INFO_FILE} ${BACKUP_DIR}${VERSION}

    #备份模块
    cd ${MOD_PATH}
	tar czf ${BACKUP_FILE_NAME} ${mod_name} && rm -rf ${mod_name}||tar_error
    mv ${BACKUP_FILE_NAME} ${BACKUP_DIR}${VERSION}

    #备份模块的模板文件
    cd ${MOD_TEMPLATE_PATH}
    tar czf ${BACKUP_FILE_NAME} ${mod_name} && rm -rf ${mod_name}||tar_error
    mv ${BACKUP_FILE_NAME} ${BACKUP_TEMPLATE_DIR}${VERSION}
    
    #备份配置文件
    cd ${SCRIPT_DIR}
    for file in $BACKUP_FILE_LIST
    do
        cp -a $file ${CONFIG_BACKUP_DIR}${VERSION}
    done
    add_log info "${FUNCNAME} done"
}

#更新函数
update()
{
    add_log info "${FUNCNAME} begin"
    cd $UPDATE_DIR
	if [[ -d ${MOD_PATH}${mod_name} || -d {MOD_TEMPLATE_PATH}${mod_name} ]];then
        add_log warn "please backup first"
        operation
    else
        mv ${mod_name} ${MOD_PATH}
        mv ${SVN_CONFIG_NAME}${mod_name} ${MOD_TEMPLATE_PATH}
        mv ${SVN_CONFIG_NAME}${config_file} ${MOD_TEMPLATE_PATH}
        cd ${SCRIPT_DIR}
        python pushfile.py -M ${mod_name}
        python saveconf.py -M ${mod_name} -c ${config_file}
        python sendfile_rysnc.py -M ${mod_name}
    fi
    add_log info "${FUNCNAME} done"

}

#启动模块函数
start()
{
    add_log info "${FUNCNAME} begin"
    cd ${SCRIPT_DIR}
    python runfile.py -M ${mod_name}
    add_log info "${FUNCNAME} done"
}

#关闭模块函数
stop()
{
    add_log info "${FUNCNAME} begin"
    cd ${SCRIPT_DIR}
    python killfile.py -M ${mod_name}
    add_log info "${FUNCNAME} done"
}

#检测进程是否启动的函数
check()
{
    add_log info "${FUNCNAME} begin"
    cd ${SCRIPT_DIR}
    sleep 60
    python checkfile.py -M ${mod_name}
    add_log info "${FUNCNAME} done"


}

rollback()
{
    add_log info "${FUNCNAME} begin"
    #删掉源文件
    cd ${SCRIPT_DIR}
    for i in ${BACKUP_FILE_LIST} ${MOD_PATH}{mod_name} ${MOD_TEMPLATE_PATH}{mod_name}
    do
        [ -e $i ] && rm -rf $i
    done

    #查看所有版本
    ls ${BACKUP_DIR}
    
    #选择回滚版本
    read -p "input you want rollback version" version
    
    #检测在同一个版本内是否有多个备份文件
    detect_back_filename()
    {
        #如果有多个文件 手动输入要回滚的文件名称
        if [ `ls|wc -l` -gt 1 ];then
            read -p "more than one file,please input full name which you want to select" filename
        elif [ `ls|wc -l` -eq 1 ];then
            filename=`ls`
        else
            add_log warn "this version has no file,choose another version to rollback"
            rollback
        fi
        tar xzf filename
    }

    #将回滚的文件复制到相关路径
        #移动模块程序
        cd ${BACKUP_DIR}
        detect_back_filename
        cp -a ${BACKUP_DIR}${version}/${filename} ${MOD_PATH}

        #移动模块的模板文件
        cd ${BACKUP_TEMPLATE_DIR}
        detect_back_filename
        cp -a ${BACKUP_TEMPLATE_DIR}${version}/${filename} ${MOD_TEMPLATE_PATH}

        #移动配置文件
        cd ${CONFIG_BACKUP_DIR}
        for f in ${BACKUP_FILE_LIST}
        do
            detect_back_filename
            cp -a ${CONFIG_BACKUP_DIR}${version}/${f} ${SCRIPT_DIR}
        done

    #停止服务 生成和传输文件 再启动服务
    stop
    python pushfile.py -M ${mod_name}
    python saveconf.py -M ${mod_name} -c ${config_file}
    python sendfile_rsync.py -M ${mod_name}
    start
    add_log info "${FUNCNAME} done"
}

#帮助函数
help()
{
exec 4<>text
cat<<EOF>text
help    print help messages
list    list all of modules
exit    exit this script
oprate do something maintance
EOF
    while read line
    do
        echo -e "${GREEN}${line}${ENDCOLOR}"
    done<text
}

#列出更新模块的函数
list_mode()
{
    add_log info "${FUNCNAME} begin"
    ls ${UPDATE_DIR}
    add_log info "${FUNCNAME} done"
}

#操作主函数
operation()
{
    if [ -z "$mod_name" ];then
        read -p "please input module name " mod_names
    fi
    for mod_name in `echo $mod_names|tr ',' ' '`
    do
        #detect_mod_type
        PS3="You are opreating module $mod_name ! Please choose an number: "
        select function in $FUNCTIONS
        do
            case $function in
             check_md5) echo "check"
                        ;;
            uncompress) echo "uncompress"
                        ;;
                backup) echo "backup"
                        ;;
                update) echo "update"
                        ;;
                 start) echo "start"
                        ;;
                  stop) echo "stop"
                        ;;
                 check) echo "check process"
                        ;;
           auto_update) check_md5
                        uncompress
                        backup
                        update
                        start
                        stop
                        check
                        ;;
                  help) $FUNCNAME
                        ;;
              continue) break
                        ;;
                  exit) exit
                        ;;
            esac
        done
    unset mod_name
    done
}


#选择操作的主循环
while :
do
    read -p  "Efeion> " answer
    case $answer in
        help)   help
                continue
                ;;
        list)   list_mode
                continue
                ;;
      oprate)   operation
                ;;
        exit)   exit
                ;;
           *)   echo "unsupport parameter"
                help
                continue
                ;;
    esac  
done
