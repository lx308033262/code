#/bin/sh
#Author: Hechuanning@feinno.com

cd `dirname $0`
source ../environment.sh

basedir="${SOFT_DIR}"
basemysql="${MYSQL_DIR}"
scriptdir="${basedir}/server/install/program/"
installdir="${basedir}/internal/"
plugdir="${installdir}plug/"
mysqlpath="${MYSQL_PATH}"
sufile="/etc/sudoers"
mysqlport="${MYSQL_PORT}"
DEFAULT=0
USER="${SOFT_NAME}"                                                                                           
PASSWORD="${SOFT_NAME}admin"                                                                                                
IP=""
mailaddr=""
mailuser=""
mailpass=""
mailport=""

STAT_FILE=${scriptdir}install.log

GREEN="\033[32;49;1m"
RED="\033[31;49;1m"
DCOLOR="\033[39;49;0m"

WORDS=`getconf LONG_BIT`

START_TIME=`date +%s`
[ `id -u` -ne 0 ] && echo "You must run this script with root" && exit

#[ -f $STAT_FILE ] || touch $STAT_FILE

version()
{
        echo -e "${GREEN}Install ${SOFT_NAME} program, version: 2.0${DCOLOR}"
        echo "update date: 2013.07.1"
        echo -e "${GREEN}Author:${DCOLOR} ${RED}hechuanning@feinno.com${DCOLOR}"
}

usage()
{
        version
        echo ""
        echo "USAGE:$0"
        echo "        [-h|--help]                      Display help information"
        echo "        [-v|-V|--version]                Display the version number"
        echo "        [-c|--clear]                     Uninstall EUT program"
        echo "        [-U|--update]                    Update server ip address"
        echo "        [-a|--mailaddr]                  Mail server address"
        echo "        [-u|--mailuser]                  Mail server user"
        echo "        [-w|--mailpass]                  Mail server user password"
        echo "        [-p|--mailport]                  Mail server port"
        echo "        [-i|--ip]                        This machine IP address"
        echo "        [-d|--deploy]                    Open the centralized deployment"
        echo ""
        echo "NOTICE:"
        echo "       The install script will help install EUT program or clean EUT program."
        echo ""
        echo -e "        ${GREEN}You must choose [-i and -a and -u and -w and -p] parameter !${DCOLOR}"
        echo -e "        ${GREEN}if you do not have a mail server,you can use 'install.sh -i ip' without -a -u -w -p,we will install a new mail server on localhost !${DCOLOR}"
        echo "..."
        echo ""
}

show_parameters()
{
        if [ "$#" -ne 1 ]
        then
            echo -e "${RED}show_parameters function must be called with one argument${DCOLOR}"
            echo ""
            echo -e "${GREEN}Example: show_parameters packer_path${DCOLOR}"
            echo "..."
            exit 1
        fi
        echo -e "${GREEN}Default install-dir:${1}${DCOLOR}"
}



create_dir()
{
        if [ "$#" -ne 1 ]
        then
            echo -e "${RED}create_dir function must be called with one argument${DCOLOR}"
            echo ""
            echo -e "${GREEN}Example: create_dir path{DCOLOR}"
            echo "..."
            exit 1
        fi
        local dir=$1
        if [ ! -d "$dir" ]
        then
            echo -e "${GREEN}Now create dir ${dir}...${DCOLOR}"
            if ! mkdir -p $dir >/dev/null 2>&1
            then
                echo -e "${RED}Sorry,Directory $dir creation failed!${DCOLOR}"
                exit 1
            fi
        #else
        #    echo -e "${RED}Sorry,directory $dir exists already, please confirm the correct after the installation !${DCOLOR}"
        #    exit 1
        fi
       return 0
}

install_jdk()
{
        cd $scriptdir >/dev/null 2>&1
        local DIR="jdk1.6.0_07"
        if [ "$WORDS" == "32" ];then
            local PAK="jdk-6u7-linux-i586.bin"
        elif [ "$WORDS" == "64" ];then
            local PAK="jdk-6u24-linux-x64.bin"
        else
            echo "can not find jdk"
            exit
        fi
        if [ ! -f "$PAK" ]
        then
            echo -e "${RED}Sorry, Cant't find install programe ${PAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        cp $PAK $plugdir
        if [ ! -x "${plugdir}${PAK}" ]
        then
            chmod 755 ${plugdir}${PAK}
        fi
        echo -e "${GREEN}Now install ${DIR}...${DCOLOR}"
        show_parameters ${plugdir}${DIR}
setup_JDK() {
expect << EXP
spawn ${plugdir}${PAK}
set timeout 30
expect {
    "More" { send "q" }
       }

expect {
    "yes or no" { send "yes\r" }
       }

expect {
    "Press Enter to continue" { send "\r" }
       }
EXP
return 0
}
            cd $plugdir
        if  rpm -qa|grep expect ;then
            setup_JDK
        else
            ./${PAK}
        fi
        if [ $? = 0 ]
        then
            rm -rf $PAK >/dev/null 2>&1
            echo ""
            echo -e "${GREEN}Install $DIR successfully !${DCOLOR}"
            cd $scriptdir >/dev/null 2>&1
            echo ""
        else
            echo ""
            echo -e "${RED}Install $DIR  failed !${DCOLOR}"
            exit 1
        fi
        if [ "$WORDS" == "64" ];then
            mv ${plugdir}jdk1.6.0_24 ${plugdir}jdk1.6.0_07
        fi
}

install_libevent()
{
        cd $scriptdir
        local DIR="libevent-1.3"
        local PAK="libevent-1.3.tar.gz"
        if [ ! -f "$PAK" ]
        then
            echo "${RED}Sorry, Cant't find install programe ${PAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}Now install ${DIR}...${DCOLOR}"
        show_parameters ${plugdir}${DIR}
        tar zxf $PAK
        cd $DIR
        ./configure --prefix=${plugdir}${DIR}
        make && make install
        if [ $? = 0 ]
        then
            if ls -tl ${plugdir}${DIR}/lib |grep -q libevent-1.3.so.1.0.3 >/dev/null 2>&1
            then
                echo ""
                echo -e "${GREEN}Install $DIR successfully !${DCOLOR}"
                cd $scriptdir >/dev/null 2>&1
                rm -rf $DIR >/dev/null 2>&1
                echo ""
            else
                echo ""
                echo -e "${RED}Install $DIR failed !${DCOLOR}"
                exit 1
            fi
        else
            echo ""
            echo -e "${RED}Install $DIR failed !${DCOLOR}"
            exit 1
        fi
}

install_memcache()
{
        local DIR=memcached
        local PAK="memcached-1.4.2.tar.gz"
        if [ ! -f "$PAK" ]
        then
            echo "${RED}Sorry, Cant't find install programe ${PAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        cp $PAK $plugdir
        echo -e "${GREEN}Now install ${DIR}...${DCOLOR}"
        show_parameters ${plugdir}${DIR}
        cd $plugdir
        tar zxf $PAK
        mv memcached-1.4.2 $DIR
        rm -rf $PAK >/dev/null 2>&1
        cd $DIR
        ./configure --with-libevent=${plugdir}libevent-1.3
        make && make install
        if [ $? = 0 ]
        then
            echo ""
            echo -e "${GREEN}Install $DIR successfully !${DCOLOR}"
            cd $scriptdir >/dev/null 2>&1
            echo ""
        else
            echo ""
            echo -e "${RED}Install $DIR failed !${DCOLOR}"
            exit 1
        fi
        return 0
}

install_ImageMagick()
{
        local DIR="ImageMagick-6.3.9"
        local PAK="ImageMagick.tar.gz"
        if [ ! -f "$PAK" ]
        then
            echo "${RED}Sorry, Cant't find install programe ${PAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}Now install ${DIR}...${DCOLOR}"
        show_parameters ${plugdir}Jmagick/imagemagick
        tar zxf $PAK
        cd $DIR
        ./configure --prefix=${plugdir}Jmagick/imagemagick
        make && make install
        if [ $? = 0 ]
        then
            if ls ${plugdir}Jmagick/imagemagick >/dev/null 2>&1
            then
                echo ""
                echo -e "${GREEN}Install $DIR successfully !${DCOLOR}"
                cd $scriptdir >/dev/null 2>&1
                rm -rf $DIR >/dev/null 2>&1
                echo ""
            else
                echo ""
                echo -e "${RED}Install $DIR failed !${DCOLOR}"
                exit 1
            fi
        else
            echo ""
            echo -e "${RED}Install $DIR failed !${DCOLOR}"
            exit 1
        fi
}

install_JMagick()
{
        local DIR="JMagick-6.2.6-0"
        local PAK="JMagick-6.2.6-0.tar.gz"
        if [ ! -f "$PAK" ]
        then
            echo "${RED}Sorry, Cant't find install programe ${PAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}Now install ${DIR}...${DCOLOR}"
        show_parameters ${plugdir}Jmagick/jmagick
        if ! grep -q "#Set Environment by EUT start" ~/.bash_profile
        then
        cat >> ~/.bash_profile <<EOF

#Set Environment by EUT start
JAVA_HOME=${plugdir}jdk1.6.0_07
JRE_HOME=${plugdir}jdk1.6.0_07/jre
PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib:
export JAVA_HOME JRE_HOME PATH CLASSPATH
export PATH=${plugdir}Jmagick/imagemagick/bin:\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:../lib:./lib:/lib:/usr/lib:/usr/libexec:${mysqlpath}lib
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${plugdir}Jmagick/imagemagick/lib:${plugdir}libevent-1.3/lib
#Set Environment by EUT end
EOF
        fi
        source ~/.bash_profile 
        tar zxf $PAK
        cd $DIR
        ./configure --prefix=${plugdir}Jmagick/jmagick --with-magick-home=${plugdir}Jmagick/imagemagick/ --with-java-home=${plugdir}jdk1.6.0_07
        make && make install
        if [ $? = 0 ]
        then
            if ls ${plugdir}Jmagick/jmagick >/dev/null 2>&1
            then
                cp -rf ${plugdir}Jmagick/jmagick/lib/jmagick.jar ${plugdir}jdk1.6.0_07/jre/lib/ext/
                if [ "$WORDS" == "32" ];then
                    cp -rf ${plugdir}Jmagick/jmagick/lib/libJMagick.so ${plugdir}jdk1.6.0_07/jre/lib/i386/
                elif [ "$WORDS" == "64" ];then
                    cp -rf ${plugdir}Jmagick/jmagick/lib/jmagick.jar ${plugdir}jdk1.6.0_07/jre/lib/ext/
                    cp -rf ${plugdir}Jmagick/jmagick/lib/libJMagick.so ${plugdir}jdk1.6.0_07/jre/lib/amd64/
                fi

                echo ""
                echo -e "${GREEN}Install $DIR successfully !${DCOLOR}"
                cd $scriptdir >/dev/null 2>&1
                rm -rf $DIR >/dev/null 2>&1
                echo ""
            else
                echo ""
                echo -e "${RED}Install $DIR failed !${DCOLOR}"
                exit 1
            fi
        else
            echo ""
            echo -e "${RED}Install $DIR failed !${DCOLOR}"
            exit 1
        fi
}

install_filesaver()
{
        local APADIR="httpd-2.2.14"
        local PHPDIR="php-5.2.11"
        local APAPAK="httpd-2.2.14.tar.gz"
        local PHPPAK="php-5.2.11.tar.gz"
        if [ ! -f "$APAPAK" ] || [ ! -f "$PHPPAK" ]
        then
            echo -e "${RED}Sorry, Cant't find install programe ${APAPAK} or ${PHPPAK},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${APADIR}" ] || [ -d "${plugdir}${PHPDIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${APADIR} or ${plugdir}${PHPDIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        echo -e "${GREEN}Now install ${APADIR}...${DCOLOR}"
        show_parameters ${plugdir}${APADIR}
        tar zxf $APAPAK
        cd $APADIR
        ./configure --prefix=${plugdir}${APADIR} --enable-module=so 
        make && make install
        if [ $? = 0 ]
        then
            if ls -tl ${plugdir}${APADIR}/bin/ |grep -q apachectl >/dev/null 2>&1
            then
                echo ""
                echo -e "${GREEN}Install $APADIR successfully !${DCOLOR}"
                cd $scriptdir >/dev/null 2>&1
                rm -rf $APADIR >/dev/null 2>&1
                echo ""
            else
                echo ""
                echo -e "${RED}Install $APADIR failed !${DCOLOR}"
                exit 1
            fi
        else
            echo ""
            echo -e "${RED}Install $APADIR failed !${DCOLOR}"
            exit 1
        fi

        echo -e "${GREEN}Now install ${PHPDIR}...${DCOLOR}"
        show_parameters ${plugdir}${PHPDIR}                                                                       
        tar zxf $PHPPAK                                                                                           
        cd $PHPDIR
        ./configure --prefix=${plugdir}${PHPDIR} --with-config-file-path=${plugdir}${PHPDIR}/lib --with-apxs2=${plugdir}${APADIR}/bin/apxs
        make && make install                                                                                      
        if [ $? = 0 ]                                                                                             
        then                                                                                                      
            if ls -tl ${plugdir}${PHPDIR}/bin/ |grep -q php >/dev/null 2>&1
            then                                                                                                  
                echo ""                                                                                           
                echo -e "${GREEN}Install $PHPDIR successfully !${DCOLOR}"         
                cp php.ini-dist ${plugdir}${PHPDIR}/lib/php.ini
                sed -i -r '/^upload_max_filesize/s/upload_max_filesize = .*[^\n\r]/upload_max_filesize = 20M/g' ${plugdir}${PHPDIR}/lib/php.ini
                sed -i -r '/^post_max_size/s/post_max_size = .*[^\n\r]/post_max_size = 20M/g' ${plugdir}${PHPDIR}/lib/php.ini
                cd $scriptdir >/dev/null 2>&1                                                                     
                rm -rf $PHPDIR >/dev/null 2>&1                                                                    
                echo ""                                                                                           
            else                                                                                                  
                echo ""                                                                                           
                echo -e "${RED}Install $PHPDIR failed !${DCOLOR}"                                                    
                exit 1                                                                                            
            fi                                                                                                    
        else                                                                                                      
            echo ""                                                                                               
            echo -e "${RED}Install $PHPDIR failed !${DCOLOR}"                                                        
            exit 1                                                                                                
        fi
        
        cp -rf ./filesaver/guid.class.php ${plugdir}${APADIR}/htdocs/
        cp -rf ./filesaver/screenshot.php ${plugdir}${APADIR}/htdocs/
        cp -rf ./filesaver/config.xml ${plugdir}${APADIR}/htdocs/
        mkdir -p ${plugdir}${APADIR}/htdocs/screenshot
        apafile="${plugdir}${APADIR}/conf/httpd.conf"
        if [ -f "$apafile" ]
        then
            sed -i -r '/^Listen 80/s/Listen 80/Listen 8017/g' $apafile
            sed -i -r '/^#ServerName www.example.com:80/s/#ServerName www.example.com:80/ServerName www.example.com:8017/g' $apafile
            sed -i -r '/AddType application\/x-gzip .gz .tgz/a\    AddType application\/x-httpd-php .php' $apafile
        else
            echo -e "${RED}Modify apache's httpd.conf file faild !${DCOLOR}"
            exit 1
        fi

}

install_supervise()
{
	cd $scriptdir
        local PAK="daemontools-0.76.tar.gz"
        local PATCH="daemontools-0.76.errno.patch"
        local DIR="admin"
        if [ ! -f "$PAK" ] || [ ! -f "$PATCH" ]
        then
            echo -e "${RED}Sorry, Cant't find install programe ${PAK} or ${PATCH},Please check your installation source files...${DCOLOR}"
            exit 1
        fi
        if [ -d "${plugdir}${DIR}" ]
        then
            echo -e "${RED}Sorry,directory ${plugdir}${DIR} exists already, please confirm the correct after the installation !${DCOLOR}"
            exit 1
        fi
        cp $PAK $plugdir
        cp $PATCH $plugdir
        echo -e "${GREEN}Now install supervise...${DCOLOR}"
        show_parameters ${plugdir}${DIR}
        cd $plugdir
        tar zxf $PAK
        cd ${DIR}/${PAK%.tar.gz}
        patch -p1 <  ../../${PATCH}
        package/install
        if [ $? = 0 ]
        then
            rm -rf ../../${PAK} >/dev/null 2>&1
            rm -rf ../../${PATCH} >/dev/null 2>&1
            echo ""
            echo -e "${GREEN}Install supervise successfully !${DCOLOR}"
            cd $scriptdir >/dev/null 2>&1
            echo ""
        else
            echo ""
            rm -rf ../../{$PAK} >/dev/null 2>&1
            rm -rf ../../${PATCH} >/dev/null 2>&1
            echo -e "${RED}Install supervise  failed !${DCOLOR}"
            exit 1
        fi
}

check_ip()
{
        if [ "$#" -ne 1 ]                                                                                          
        then                                                                                                       
            echo -e "${RED}check_ip function must be called with one arguments${DCOLOR}"                                                
            echo ""
            echo -e "${GREEN}Example: check_ip IP${DCOLOR}"                                                              
            echo "..."                                                                                             
            exit 1                                                                                                 
        fi
        local IP=$1
        if [ "$IP"x = x ]                                                                                                 
        then
            usage                                                                                                         
            exit 1                                                                                                        
        else                                                                                                              
            local LIP=`echo $IP |grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`
            if [ "$LIP"x = x ]
            then
                echo -e "${RED}You enter the server IP address $IP is not correct, please input again!${DCOLOR}"
                exit 1
            fi
            local ipstr=""
            local nic=`ls /etc/sysconfig/network-scripts/ |grep ifcfg- |awk -F- '{print $2}'`
            for i in $nic
            do
              local ip=`/sbin/ifconfig $i |awk '/inet addr/ {print $2}' |awk -F: '{print $2}'`
              if [ -n "$ip" ] && [ "$ip"x = `echo $ip |grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`x ]   
              then
                  if [ "$LIP" = "$ip" ] 
                  then
                      ipstr=${ipstr}${ip}
                  fi
              fi
            done
            if [ "$LIP" != "$ipstr" ]
            then
                echo -e "${RED}You enter the IP address $LIP is not server's IP address, please enter again server's IP address ! Or server's IP address abnormalities !${DCOLOR}" 
                exit 1
            fi 
        fi
        return 0
}

create_user()
{
        if [ "$#" -ne 2 ]                                                                                          
        then                                                                                                       
            echo -e "${RED}create_user function must be called with two arguments${DCOLOR}"                                                
            echo ""
            echo -e "${GREEN}Example: create_user username password${DCOLOR}"                                                              
            echo "..."                                                                                             
            exit 1                                                                                                 
        fi 
        local user=$1
        local password=$2
        isuser=`id $user 2>/dev/null`
        if [ -z "$isuser" ]
        then
            echo -e "${GREEN}Not exists $user user ,now create it...${DCOLOR}"
            if /usr/sbin/useradd $user >/dev/null 2>&1
            then
                echo -e "${GREEN}User $user create successfully !${DCOLOR}"
                echo ""
                echo -e "${GREEN}Now create ${user}'s Password...${DCOLOR}"
                echo ""
                echo "$password"|passwd --stdin $user >/dev/null 2>&1
                if [ $? = 0 ]
                then
                    GROUP=`id -gn $user`
                    echo -e "${GREEN}${user}'s password create successfully !${DCOLOR}"
                    echo ""
                else
                    echo -e "${RED}${user}'s password create failed !${DCOLOR}"
                    echo ""
                    exit 1
                fi
            else
                echo -e "${RED}User $user create failed !${DCOLOR}"
                exit 1
            fi
        else
            echo -e "${RED}User $user is aleady exists,do not need created !${DCOLOR}"
            PASSWORD="The password is still the account original password"
            GROUP=`id -gn $user`
        fi
        return 0
}

user_var()
{
        if [ "$#" -ne 1 ]                                                                                          
        then                                                                                                       
            echo -e "${RED}user_var function must be called with one arguments${DCOLOR}"                                                
            echo ""
            echo -e "${GREEN}Example: user_var username ${DCOLOR}"                                                              
            echo "..."                                                                                             
            exit 1                                                                                                 
        fi 
        local username=$1
        local profile="/home/${username}/.bash_profile"
        if [ -f "$profile" ]
        then
            if ! grep -q "#Set Environment by EUT start" $profile
            then
cat >> $profile <<EOF                

#Set Environment by EUT start
JAVA_HOME=${plugdir}jdk1.6.0_07
JRE_HOME=${plugdir}jdk1.6.0_07/jre
PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib:
export JAVA_HOME JRE_HOME PATH CLASSPATH
export PATH=${plugdir}Jmagick/imagemagick/bin:\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:../lib:./lib:/lib:/usr/lib:/usr/libexec:${mysqlpath}lib
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${plugdir}Jmagick/imagemagick/lib:${plugdir}libevent-1.3/lib
#Set Environment by EUT end
EOF
                source $profile
            fi
        else
            local efile="/etc/profile"
            echo -e "${RED}File $profile does not exist,Add environment variable in $efile file${DCOLOR}"
            echo ""
            if ! grep -q "#Set Environment by EUT start" $efile
            then
cat >> $efile <<EOF                

#Set Environment by EUT start
JAVA_HOME=${plugdir}jdk1.6.0_07
JRE_HOME=${plugdir}jdk1.6.0_07/jre
PATH=\$JAVA_HOME/bin:\$JRE_HOME/bin:\$PATH
CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib:
export JAVA_HOME JRE_HOME PATH CLASSPATH
export PATH=${plugdir}Jmagick/imagemagick/bin:\$PATH
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:../lib:./lib:/lib:/usr/lib:/usr/libexec:${mysqlpath}lib
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${plugdir}Jmagick/imagemagick/lib:${plugdir}libevent-1.3/lib
#Set Environment by EUT end
EOF
                source $efile
            fi
        fi
        local limit="/etc/security/limits.conf"
        if [ -f "$limit" ]
        then
            if ! grep -q "#start user limit..." $limit
            then
cat >> $limit <<EOF    
 
#start user limit...
@$username               soft    core            2048000
@$username               hard    core            2048000
@$username               soft    fsize           unlimited
@$username               hard    fsize           unlimited
@$username               soft    data            unlimited
@$username               hard    data            unlimited
@$username               soft    nproc           65535
@$username               hard    nproc           65535
@$username               soft    stack           unlimited
@$username               hard    stack           unlimited
@$username               soft    nofile          409600
@$username               hard    nofile          409600
#end user limit...
EOF
            fi
        else
            echo -e "${RED}File $limit does not exist, unable to add user ${username}'s resource constraints !${DCOLOR}"
        fi
        local sysctl="/etc/sysctl.conf"
        if [ -f "$sysctl" ]
        then
            if ! grep -q "#start add tcp_timestamps" $sysctl
            then
cat >> $sysctl <<EOF

#start add tcp_timestamps
net.ipv4.tcp_timestamps = 0
#end add tcp_timestamps
EOF
            fi
        else
            echo -e "${RED}File $sysctl does not exist, unable to add tcp_timestamps !${DCOLOR}"
        fi

}

mod_sudo()
{
        if [ "$#" -ne 3 ]
        then
            echo -e "${RED}mod_sudo function must be called with three arguments${DCOLOR}"                                          
  

            echo ""
            echo -e "${GREEN}Example: mod_sudo username mysql_path sudofile ${DCOLOR}" 
            echo "..."                                                                                             
            exit 1
        fi
        local user=$1
        local mysql_path=$2
        local sudofile=$3

        echo -e "${GREEN}Now modify file $sudofile ...!${DCOLOR}"
        if [ -f "$sudofile" ]
        then
            sed -i -r 's/Defaults    requiretty/#Defaults    requiretty/g' $sudofile
            sed -i -r '/^root/a\'$user'     ALL=(root)      NOPASSWD:'$mysql_path'bin/mysqld_safe,NOPASSWD:/sbin/iptables' $sudofile
            if grep -q "${mysql_path}bin/mysqld_safe" $sudofile
            then
                echo -e "${GREEN}Modify file $sudofile successfully !${DCOLOR}"
            else
                echo -e "${RED}Modify file $sudofile failed !${DCOLOR}"                                           
                exit 1                                                                                            
            fi                                                                                                    
        else                                                                                                      
            echo -e "${RED}File $sudofile does not exist, abnormal exit !${DCOLOR}"                               
            exit 1                                                                                                
        fi                                                                                                        
}

install_main()
{
        create_dir $plugdir
        install_jdk
        install_libevent
        install_memcache
        install_ImageMagick
        install_JMagick
        echo ""
        echo -e "${GREEN}Install all third-party software successfully !${DCOLOR}"
        echo ""
}

mod_email()
{
        local mopfile="${installdir}webhome/mop_ims_01/WEB-INF/classes/constant.properties"
        local portfile="${installdir}webhome/portal_ims_01/WEB-INF/classes/ApplicationResources.properties"
        local msmsfile="${installdir}webhome/msms_gw_01/WEB-INF/classes/mail_template.properties"
        #EUTv2.0 add ...
        local ospfile="${installdir}webhome/osp_ims_01/WEB-INF/classes/mail.properties"
        
        if [ -f "$mopfile" ] && [ -f "$portfile" ]
        then
            sed -i -r '/^mail.host=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$mailaddr'/g' $mopfile
            sed -i -r '/^mail.port=/s/[0-9]{1,6}/'$mailport'/g' $mopfile
            sed -i -r '/^mail.user=/s/mail.user=.*[^\n\r]/mail.user='${mailuser}'/g' $mopfile
            sed -i -r '/^mail.password=/s/mail.password=.*[^\n\r]/mail.password='${mailpass}'/g' $mopfile
            sed -i -r '/^mail.from=/s/mail.from=.*[^\n\r]/mail.from='${mailuser}'/g' $mopfile
            sed -i -r '/^mail.host=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$mailaddr'/g' $portfile
            sed -i -r '/^mail.port=/s/[0-9]{1,6}/'$mailport'/g' $portfile
            sed -i -r '/^mail.user=/s/mail.user=.*[^\n\r]/mail.user='${mailuser}'/g' $portfile
            sed -i -r '/^mail.password=/s/mail.password=.*[^\n\r]/mail.password='${mailpass}'/g' $portfile
            sed -i -r '/^mail.from=/s/mail.from=.*[^\n\r]/mail.from='${mailuser}'/g' $portfile
            sed -i -r '/^mail_uri=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$mailaddr'/g' $msmsfile
            sed -i -r '/^mail_port=/s/[0-9]{1,6}/'$mailport'/g' $msmsfile
            sed -i -r '/^mail_user=/s/mail_user=.*[^\n\r]/mail_user='${mailuser}'/g' $msmsfile
            sed -i -r '/^mail_pass=/s/mail_pass=.*[^\n\r]/mail_pass='${mailpass}'/g' $msmsfile
            sed -i -r '/^frommailAddress=/s/frommailAddress=.*[^\n\r]/frommailAddress='${mailuser}'/g' $msmsfile
            sed -i -r '/^mailurl=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$mailaddr'/g' $ospfile
            sed -i -r '/^mailport=/s/[0-9]{1,6}/'$mailport'/g' $ospfile
            sed -i -r '/^username=/s/username=.*[^\n\r]/username='${mailuser}'/g' $ospfile
            sed -i -r '/^password=/s/password=.*[^\n\r]/password='${mailpass}'/g' $ospfile
        else
            echo -e "${RED}Configure mail server information failed !${DCOLOR}"
            exit 1
        fi
}

installmysql()
{
        MYPORT=$mysqlport
        INSTALLDIR=`dirname $mysqlpath`
        
        show_usage()
        {
                echo ""
                echo "USAGE:$0"
                echo "        [-h|--help]                      Display help information"
                echo "        [-w|--word]                      32-bit version or 64-bit version, you must choose one of 32 or 64, this parameter not configured for 32-bit by default"
                echo "        ..."
                echo ""
        }
        
        show_mysqlparameters()
        {
            echo -e "${GREEN}version:$WORDS,install-dir:$INSTALLDIR,port:$MYPORT${DCOLOR}"
        }
        
        find_mysqlpackege()
        {
            if [ $WORDS -eq 32 ]
            then
                if [ ! -f ./mysql-5.1.50.tar.gz ]
                then
                    echo -e "${RED}Sorry ,Can't find instatll programe mysql-5.0.87.tar.gz...${DCOLOR}"
                    exit 1
                else
                    INSTALLPKT=mysql-5.1.50.tar.gz
                fi
            elif [ $WORDS -eq 64 ]
            then
                if [ ! -f ./mysql-advanced-5.1.49sp1-linux-x86_64-glibc23.tar.gz ]
                then
                    echo -e "${RED}Sorry,Can't find install progame mysql-enterprise-5.0.64...${DCOLOR}"
                    exit 1
                else
                    INSTALLPKT=mysql-advanced-5.1.49sp1-linux-x86_64-glibc23.tar.gz
                fi
            fi
        
        }
        
        create_mysqlinstalldir()
        {
            if [ -z  $INSTALLDIR ]
            then
                echo -e "${RED}Sorry,Can't find install path,it's null...${DCOLOR}"
                exit 1
            else
                if [ -d ${INSTALLDIR}/mysql${MYPORT} ]
                then
                    echo -e "${RED}Sorry,${INSTALLDIR}/mysql${MYPORT} is aleady exists,please check install-route ...${DCOLOR}"
                    exit 1
                else
                    echo -e "${GREEN}Now create dir ${INSTALLDIR}...${DCOLOR}"
                    mkdir -p $INSTALLDIR
                fi
            fi
        }
        
        initialize_mysqldata()
        {
        
            cd $INSTALLDIR/mysql${MYPORT}/
        
            if [ ! -f ./initdata/inetdataschema.sql ]
            then
                echo -e "${RED}Sorry,Can't find inetdataschema.sql,Please check your install packege...${DCOLOR}"
                exit 1
            else
                if [ ! -f ./initdata/initialize.conf ]
                then
                    echo -e "${RED}Sorry,Can't find initialize.conf,Please chenk your install packege...${DCOLOR}"
                    exit 1
                fi
            fi
        
            ./bin/mysql -S $INSTALLDIR/mysql${MYPORT}/mysql.sock -uroot -psecret <./initdata/inetdataschema.sql >/dev/null 2>&1
            if [ $? -ne 0 ]
            then
                echo -e "${RED}Error,initialize data failed ! ${DCOLOR}"
                exit 1
            fi
            ./bin/mysql -S $INSTALLDIR/mysql${MYPORT}/mysql.sock -uroot -psecret -e "flush privileges;"
            if [ $? -ne 0 ]
            then
                echo -e "${RED}Error,initialize data failed ! ${DCOLOR}"
                exit 1
            fi
        }
        
        show_corpinfo()
        {
            echo -e "${GREEN}企业名称：初始化企业${DCOLOR}"
            echo -e "${GREEN}企业代码：2000100001${DCOLOR}"
            echo -e "${GREEN}企业管理员：admins${DCOLOR}"
            echo -e "${GREEN}管理员默认密码：aaa111${DCOLOR}"
        }
        
        install_mysqlmain()
        {
            date
            echo -e "${GREEN}Now install and initialize begin...${DCOLOR}"
            echo -e "${GREEN}Now find install packege...${DCOLOR}"
            find_mysqlpackege
            echo -e "${GREEN}Now create install route...${DCOLOR}"
            create_mysqlinstalldir
        
            echo -e "${GREEN}Now install mysqld...${DCOLOR}"
            cp ./$INSTALLPKT $INSTALLDIR
            cd $INSTALLDIR
            tar -xzf $INSTALLPKT
            rm -rf $INSTALLPKT
	    if [ $WORDS -eq 32 ];then
            	mv mysql-advanced-5.1.50-linux-i686-glibc23 mysql${MYPORT}
	    elif [ $WORDS -eq 64 ];then
		        mv mysql-advanced-5.1.49sp1-linux-x86_64-glibc23 mysql${MYPORT}
	    fi
        
            echo -e "${GREEN}Now create my.cnf...${DCOLOR}"
            cd mysql${MYPORT}
echo > my.cnf
cat >> my.cnf << EOF
[client]
port            = $MYPORT
socket          = $INSTALLDIR/mysql${MYPORT}/mysql.sock

[mysqld]
port            = $MYPORT
socket          = $INSTALLDIR/mysql${MYPORT}/mysql.sock
datadir         =$INSTALLDIR/mysql${MYPORT}/data/

EOF
	    mem=`cat /proc/meminfo |head -n 1|awk '{print $2/1024}'|awk -F'.' '{print $1}'`
	    if [ $mem -ge 3900 -a $mem -lt 8000 ];then
		cat myconf-4G >> my.cnf
	    elif [ $mem -ge 8000 ];then
                if [ $WORDS -eq "64" ];then
	    	    cat myconf-8G >> my.cnf
                else
                    cat myconf-4G >> my.cnf
                fi
	    else
		cat myconf>>my.cnf
	    fi
        	
            echo -e "${GREEN}Now create system user for DB...${DCOLOR}"
            ismysql=`id mysql 2>/dev/null`
            if [ -z "$ismysql" ]
            then
                echo -e "${GREEN}Not exists mysql user ,now create it...${DCOLOR}"
                groupadd mysql
                useradd mysql -g mysql
                mysqlgrp="mysql"
            else
                mysqlgrp=`id -gn mysql`
            fi
        
            chown -R mysql.$mysqlgrp $INSTALLDIR/mysql${MYPORT}
        
            echo -e "${GREEN}Now start mysqld services...${DCOLOR}"
        
            ./bin/mysqld_safe --defaults-file=$INSTALLDIR/mysql${MYPORT}/my.cnf -umysql&
            until [   -S $INSTALLDIR/mysql${MYPORT}/mysql.sock ]
            do
                sleep 1
            done
            echo -e "${GREEN}Now initialize data...${DCOLOR}"
            initialize_mysqldata
        }
        
        MTEMP=`getopt -o hw: --long help,word: -- "$@" 2>/dev/null`
        
        
        if [ $? != 0 ]
        then
                echo "INSTALL_ERROR: wrong option!"
                echo ""
                show_usage
                exit 1
        fi
        
        eval set -- "$MTEMP"
        
        while true
        do
           if [ -z "$1" ]
           then
               break
           fi
        
           case "$1" in
                -h|--help) show_usage; exit 0;;
                -w|--word) WORDS=$2;OSFLAG="Y";shift 2;;
                --) shift;;
                *) echo "INSTALL_ERROR: wrong option!"; echo ""; show_usage; exit 1 ;;
                esac
        done
                
        echo -e "${GREEN}Now install mysqld defaults...${DCOLOR}"
        echo -e "${GREEN}Installation information below:${DCOLOR}"
        show_mysqlparameters
        echo ""
        install_mysqlmain
}

initialize_gd_data()
{
        host=$1
        mytools="${mysqlpath}bin/mysql -S ${mysqlpath}mysql.sock -uroot -psecret"
        pname=`basename $mysqlpath`
        
        if [ "$#" -ne 1 ]
        then
            echo -e "${RED}$0 function must be called with one arguments${DCOLOR}"
            echo ""
            echo -e "${GREEN}Example: $0 IP${DCOLOR}"
            echo -e "${GREEN}...${DCOLOR}"
            exit 1
        fi
        
        cd $scriptdir >/dev/null 2>&1
	sh create_month_table.sh
        sh navi_daily_table.sh
        if [ -f ./initialize_data.conf ]
        then   
            sed -e 's/${host}/'$host'/g' initialize_data.conf  >initialize_data.conf.tmp
            if ps -ef |grep $pname |grep -v grep >/dev/null 2>&1
            then
                if netstat -anl |grep -i listen |grep :${mysqlport} >/dev/null 2>&1
                then
                    while read line
                    do
                      if echo $line |grep -q "^#"
                      then
                          continue
                      fi
                      $mytools -e "$line" 
                      if [ $? -ne 0 ]
                      then
                          echo -e "${RED}Error,initialize gd data failed ! ${DCOLOR}"
                          exit 1
                      fi
                    done<initialize_data.conf.tmp
                    rm -rf initialize_data.conf.tmp
                else
                    rm -rf initialize_data.conf.tmp
                    echo  -e "${RED}Error,mysql server is not running ! initialize gd data failed !${DCOLOR}"
                fi
            else
                rm -rf initialize_data.conf.tmp
                echo -e "${RED}Error,mysql server is not running ! initialize gd data failed !${DCOLOR}"
            fi
        else
            echo -e "${RED}Sorry ,Can't find  initialize data file initialize_data.conf,Please check your installation source files...${DCOLOR}"
            exit 1
        fi
}

replace_configure_file()
{
  echo -e "${GREEN}Now modify the program configuration files,Please waitting...${DCOLOR}"
  echo ""
  soapfile="${installdir}pgm/soap/soap_01/config/soap.conf"
  imfile="${installdir}pgm/im/im_01/config/config.system"
  msrpgwfile="${installdir}pgm/msrpgw/msrpgw_01/config/config.system"
  msrpfile="${installdir}pgm/msrp/msrp_01/config/ip_map.conf"
  msrpfile1="${installdir}pgm/msrp/msrp_01/config/msrp_server.conf"
  ssfile="${installdir}pgm/ss/ss_01/config/config.system"
  sbcfile="${installdir}pgm/sbc/sbc_01/config/config.system"
  Mopfile="${installdir}webhome/mop_ims_01/WEB-INF/classes/systemConfig.xml"
  Porfile="${installdir}webhome/portal_ims_01/WEB-INF/classes/systemConfig.xml"
  Porfile1="${installdir}webhome/portal_ims_01/WEB-INF/classes/jdbc.properties"
  Mefile="${installdir}webhome/media_ims_01/WEB-INF/classes/Application.properties"
  psfile="${installdir}pgm/ps/ps_01/config/config.system"
  cagwfile="${installdir}pgm/cagw/cagw_01/config/config.system"
  msfile="${installdir}webhome/msms_gw_01/WEB-INF/classes/sip.properties"
  msfile1="${installdir}webhome/msms_gw_01/WEB-INF/classes/jdbc.properties"
  fopenfile="${installdir}webhome/feinnoopen_01/WEB-INF/classes/system.properties"
  fopenfile1="${installdir}webhome/feinnoopen_01/WEB-INF/classes/jdbc.properties"
  fopenfile2="${installdir}webhome/feinnoopen_01/WEB-INF/classes/db.properties"
  webimfile=${installdir}pgm/webim/webim_01/config/config.system
  webimfile1=${installdir}/webhome/webimeut_01/WEB-INF/classes/systemConfig.xml
  webimfile2=${installdir}/webhome/webimeut_01/WEB-INF/classes/db.properties
  ippbxfile=${installdir}/webhome/ippbx_ims_01/WEB-INF/classes/systemConfig.xml
  ippbxfile1=${installdir}/webhome/ippbx_ims_01/WEB-INF/classes/db.properties

  #EUTv2.0 add 
  ftfile="${installdir}pgm/ft/ft_01/config/config.system"
  ftscript="${installdir}pgm/ft/ft_01/bin/ft_delete.sh"
  ospfile="${installdir}/webhome/osp_ims_01/WEB-INF/classes/jdbc.properties"
  stgfile="${installdir}pgm/stg/stg_01/config/config.system"
  
  ##################
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $soapfile
  sed -i -r '/udp.url/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msfile
  sed -i -r '/noteurl/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msfile
  sed -i -r '/mopsmsinbox/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $fopenfile
  sed -i -r '/asekey=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/211.99.191.99/g' $fopenfile
    
  #replace database ip
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $fopenfile1
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $fopenfile2
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $msfile1
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $webimfile2

  sed -i -r '/<mediaServer>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $webimfile1
  sed -i -r '/<oauth_IP>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $webimfile1
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $imfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ssfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $sbcfile
  sed -i -r 's#<MEDIAPORT RANGE="[0-9]*"> [0-9]* </MEDIAPORT>#<MEDIAPORT RANGE="2000"> 12001 </MEDIAPORT>#g' $sbcfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msrpgwfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msrpfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $msrpfile1
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Mopfile
  sed -i -r '/<ssoServerDomain>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/211.99.191.99/g' $Mopfile
  sed -i -r '/<mopurl>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Porfile
  sed -i -r '/<mediaServer>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Porfile
  sed -i -r '/<imagespath>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Porfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Porfile1
  sed -i -r '/^hostandport=/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $Mefile
  sed -i -r '/<LOCALIP>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/1' $psfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $cagwfile
  sed -i -r '/IMSCORE/,/IMSCORE/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/1' $psfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $webimfile
  sed -i -r '/<ServerDomain>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ippbxfile
  sed -i -r '/<mopPlatformSsoLoginUrl>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ippbxfile
  sed -i -r '/<videoMeetPlatformURL>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ippbxfile
  sed -i -r '/<MediaServer>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ippbxfile
  sed -i -r '/<AsteriskServer>/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ippbxfile
  sed -i -r '/confvideo_r_0.url=jdbc/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:3306/'$IP':7000/g' $ippbxfile1
  sed -i -r '/confvideo_w_0.url=jdbc/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:3306/'$IP':7000/g' $ippbxfile1
  sed -i -r '/confvideo_r_0.url=jdbc/s/ubi/asterisk/g' $ippbxfile1
  sed -i -r '/confvideo_w_0.url=jdbc/s/ubi/asterisk/g' $ippbxfile1
  sed -i -r '/confvideo_r_0.user/s/confvideo_r_0.user=.*/confvideo_r_0.user=pgm/g' $ippbxfile1
  sed -i -r '/confvideo_r_0.password/s/confvideo_r_0.password=.*/confvideo_r_0.password=pgmfetion/g' $ippbxfile1
  sed -i -r '/confvideo_w_0.user/s/confvideo_w_0.user=.*/confvideo_w_0.user=pgm/g' $ippbxfile1
  sed -i -r '/confvideo_w_0.password/s/confvideo_w_0.password=.*/confvideo_w_0.password=pgmfetion/g' $ippbxfile1

  #EUTv2.0 add 
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $ftfile
  sed -i -r 's/DAY_INTERVAL=.*/DAY_INTERVAL=7/g' $ftscript
  sed -i -r 's/memcached.server_1.ip=.*/memcached.server_1.ip='$IP'/g' $ospfile
  sed -i -r 's/memcached.server_1.port=.*/memcached.server_1.port=8040/g' $ospfile
  sed -i -r 's/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/'$IP'/g' $stgfile
  sed  -i -r  '/<PROTOCOL> RTP <\/PROTOCOL>/,/<TO>.*<\/TO>/s/PORTSTART=".*" PORTEND=".*"/PORTSTART="10000" PORTEND="14000"/' $stgfile
  sed -i -r 's#<imsClientVersonIsHide>.*</imsClientVersonIsHide>#<imsClientVersonIsHide>1</imsClientVersonIsHide>#g' $Mopfile
  sed -i -r 's#<imsIppbxScope>.*</imsIppbxScope>#<imsIppbxScope>Audio</imsIppbxScope>#g' $Mopfile
  sed -i -r 's#<AccountSyncDefaultScope>.*</AccountSyncDefaultScope>#<AccountSyncDefaultScope>Audio</AccountSyncDefaultScope>#g' $ippbxfile
}

update_gd_data()
{
        local host=$1
	local IP=$1
        mytools="${mysqlpath}bin/mysql -S ${mysqlpath}mysql.sock -uroot -psecret"
        pname=`basename $mysqlpath`
        
        if [ "$#" -ne 1 ]
        then
            echo -e "${RED}$0 function must be called with one arguments${DCOLOR}"
            echo ""
            echo -e "${GREEN}Example: $0 IP${DCOLOR}"
            echo -e "${GREEN}...${DCOLOR}"
            exit 1
        fi

        if netstat -anl |grep -i listen |grep :${mysqlport} >/dev/null 2>&1
            then :
        else
            echo -e "${RED}Error,mysql server is not running ! initialize gd data failed !${DCOLOR}"
	fi

        cd $scriptdir >/dev/null 2>&1
        if [ -f ./initialize_data.conf ]
        then   
	    fgrep '${host}' initialize_data.conf|grep -v '^#'|awk -F'[()]' '{split($1,i," ")split($2,j,",")split($4,k,",");for(s in j)if(k[s]~/host/ && i[3] != "scfg_db.scfg_ip_whitelist")print "update "i[3]" set "j[s]"="k[s]" where "j[1]"="k[1];if(i[3] == "scfg_db.scfg_ip_whitelist")print $0}'|sed -e 's/${host}/'$host'/g' -e 's/insert into/replace into/g' >> initialize_data.conf.tmp
	else
	    echo -e "${RED}Sorry ,Can't find  initialize data file initialize_data.conf,Please check your installation source files...${DCOLOR}"
	fi

	while read line
	do
	    $mytools -e "$line"
            if [ $? -ne 0 ]
               then
                   echo -e "${RED}Error,initialize gd data failed ! ${DCOLOR}"
                   exit 1
            fi
	done<initialize_data.conf.tmp
	rm -f initialize_data.conf.tmp
	replace_configure_file
        rm -rf $STAT_FILE
}

install_postfix(){
if rpm -qa|grep sendmail;then
    local line=`ps aux|grep sendmail|grep -v grep|wc -l`
    [ $line -ne 0 ] || service sendmail stop
    service sendmail stop
    chkconfig --level 345 sendmail off
fi
if ! `which postfix`;then
postfixver=postfix-2.6.8
######################build_account##############
groupadd postdrop
groupadd -g 1000 postfix
useradd -u 1000 -g postfix -s /sbin/nologin -G postdrop postfix
###################setup_postfix#################
cd $scriptdir >/dev/null 2>&1
tar zxvf $postfixver.tar.gz
cd $postfixver
chmod 755 ./postfix-install
make makefiles
make
if [ $? != 0 ];then
    echo "postfix depend some lib,install failure,check your system lib"
fi
./postfix-install -non-interactive \
install_root=/ tempdir=/tmp \
config_directory=/etc/postfix \
command_directory=/usr/sbin \
daemon_directory=/usr/libexec/postfix \
data_directory=/var/lib/postfix \
html_directory=no \
mail_owner=postfix \
mailq_path=/usr/bin/mailq \
manpage_directory=/usr/local/man \
newaliases_path=/usr/bin/newaliases \
queue_directory=/var/spool/postfix \
readme_directory=no \
sendmail_path=/usr/sbin/sendmail \
setgid_group=postdrop
cd ..
rm -rf $postfixver
fi
#########add user account###########
useradd -s /sbin/nologin eutadmin 
echo "eutmail"|passwd --stdin eutadmin
local `ipcalc  -m $IP`
#########modify configure file###########
cat > /etc/postfix/main.cf << EOF
inet_interfaces = all
myhostname = mail.eut.com
mydomain = eut.com
myorigin = \$mydomain
mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain, mail.\$mydomain
home_mailbox = Maildir/
smtpd_client_restrictions = permit_mynetworks, reject_unknown_client
mynetwork=$IP/$NETMASK
relay_domains = eut.com
EOF
postfix start
postfix reload
echo "postfix start" >> /etc/rc.local
}

install_neededpackage()
{
       cd $scriptdir >/dev/null 2>&1
       if [ "$WORDS" == "32" ];then
           local PACKPATH="${scriptdir}NeededPackage/32BIT/"
       elif [ "$WORDS" == "64" ];then
           local PACKPATH="${scriptdir}NeededPackage/64BIT/"
       else
           echo "${RED}Can not find install needed rpm package !${DCOLOR}"
           exit 1
       fi
       echo -e "${GREEN}Now install needed rpm package........ ${DCOLOR}"
       rpm -ivh ${PACKPATH}Jmagick/*.rpm
       rpm -ivh ${PACKPATH}libevent/*.rpm
       rpm -ivh ${PACKPATH}php/*.rpm
       rpm -ivh ${PACKPATH}dbproxy/*.rpm
       echo -e "${GREEN}Install needed rpm package successfully ! ${DCOLOR}"

}

show_corpinfo_osp()
{
    echo -e "${GREEN}请登录 OSP运营支撑平台 开通企业信息${DCOLOR}"
    echo -e "${GREEN}OSP运营支撑平台登录信息如下：${DCOLOR}"
    echo -e "${GREEN}用户名：admin${DCOLOR}"
    echo -e "${GREEN}密码：aaaa1111${DCOLOR}"
}

clean_install()
{
pkill -9 -u $SOFT_NAME
postfix stop
echo -e "${GREEN}Now clean the user ${USER}...${DCOLOR}"
/usr/sbin/userdel -rf $USER >/dev/null 2>&1
echo -e "${GREEN}Now clean the postfix...${DCOLOR}"
/usr/sbin/userdel -rf postfix >/dev/null 2>&1
/usr/sbin/userdel -rf eutadmin >/dev/null 2>&1
/usr/sbin/groupdel postdrop
rm -rf /etc/postfix >/dev/null 2>&1
rm -rf /usr/local/postfix >/dev/null 2>&1
rm -rf /usr/sbin/post* > /dev/null 2>&1
rm -f $STAT_FILE
sed -i '/mysql/d' /etc/rc.local 
sed -i '/postfix/d' /etc/rc.local 
        echo ""
        echo -e "${GREEN}Now clean the user ${USER}'s environment variables...${DCOLOR}"
        echo ""
        sed -i -r '/#Set Environment by EUT start/,/#Set Environment by EUT end/d' /etc/profile   
        sed -i -r '/#Set Environment by EUT start/,/#Set Environment by EUT end/d' ~/.bash_profile
        sed -i -r '/#start user limit.../,/#end user limit.../d' /etc/security/limits.conf
        sed -i -r '/#start add tcp_timestamps/,/#end add tcp_timestamps/d' /etc/sysctl.conf
        sed -i -r '/^'$USER'/d' /etc/sudoers
        sed -i -r 's/#Defaults    requiretty/Defaults    requiretty/g' /etc/sudoers 
        echo -e "${GREEN}Now clean mysql server powered up...${DCOLOR}"
        echo ""
        sed -i -r '/#Add mysql server powered up.../,/'$USER'/d' /etc/rc.local
        echo -e "${GREEN}Now clean EUT server powered up...${DCOLOR}"
        echo ""
        sed -i -r '/#Add EUT server powered up.../,/sh EUT.sh start/d' /etc/rc.local 
        echo -e "${GREEN}Now clean directory $installdir... ${DCOLOR}"
        echo ""
        rmdir=`echo $installdir |sed 's/\/$//'`
        rm -rf $rmdir >/dev/null 2>&1
        echo -e "${GREEN}Now clean supervise... ${DCOLOR}"
        echo ""
        rm -rf /service >/dev/null 2>&1
        rm -rf /command >/dev/null 2>&1
        rm -rf /usr/local/bin/supervise >/dev/null 2>&1
        echo -e "${GREEN}Now clean ${USER}'s crontab... ${DCOLOR}"
        rm -rf /var/spool/cron${SOFT_DIR}
        echo ""
        echo -e "${GREEN}Now clean mysql server... ${DCOLOR}"
        echo ""
        if ps -ef |grep mysql${mysqlport} |grep -v grep >/dev/null 2>&1
        then
            ${mysqlpath}bin/mysqladmin shutdown -S ${mysqlpath}mysql.sock -uroot -psecret >/dev/null 2>&1
            sleep 3
            ${mysqlpath}bin/mysqladmin shutdown -S ${mysqlpath}mysql.sock -uroot -psecret >/dev/null 2>&1
            sleep 1
            rm -rf $basemysql >/dev/null 2>&1
            if [ -d "$basemysql" ];then rm -rf $basemysql >/dev/null 2>&1;fi
        else
            rm -rf $basemysql >/dev/null 2>&1
            if [ -d "$basemysql" ];then rm -rf $basemysql >/dev/null 2>&1;fi
        fi
        if [ -d "$basemysql" ]
        then
            echo -e "${GREEN}Now clean mysql server failed ! ${DCOLOR}"
            exit 1
        else
            echo -e "${GREEN}Now clean mysql server successfully !${DCOLOR}"
            chown -R root.root ${SOFT_DIR}
        fi
        killall -9 svscan
        echo ""
        echo -e "${GREEN}Uninstall EUT to complete...! ${DCOLOR}"
        echo -e "${GREEN}exit...! ${DCOLOR}"
        echo ""
}



TEMP=`getopt -o hvVU:ca:u:w:p:i:d --long help,version,update,clear,mailaddr:,mailuser:,mailpass:,mailport:,ip:,deploy -- "$@" 2>/dev/null`


if [ $? != 0 ]
then
        echo -e "${RED}INSTALL_ERROR: wrong option!${DCOLOR}"
        echo ""
        usage
        exit 1
fi

eval set -- "$TEMP"

DEPLOY=0

while true
do
   if [ -z "$1" ]
   then
       break 1
   fi

   case "$1" in
        -h|--help) usage; exit 0;;
        -v|-V|--version) version; exit 0;;
        -c|--clear) clean_install;exit 0;;
	    -U|--update) update_gd_data $2;exit 0;;
        -a|--mailaddr) mailaddr=$2;shift 2;;
        -u|--mailuser) mailuser=$2;shift 2;;
        -w|--mailpass) mailpass=$2;shift 2;;
        -p|--mailport) mailport=$2;shift 2;;
        -i|--ip) IP=$2;OSFLAG="Y";shift 2;;
        -d|--deploy) DEPLOY=1; shift;;
        --) shift;;
        *) echo -e "${RED}INSTALL_ERROR: wrong option!${DCOLOR}"; echo ""; usage; exit 1 ;;
        esac
done


if [ "$IP"x = x ]
then
    echo -e "${RED}Error,You must choose [-i|--ip] parameter !${DCOLOR}"
    echo ""
    echo ""
    usage
    exit 1
else
    echo -e "${GREEN}Now check you enter IP address format...${DCOLOR}"
    check_ip $IP
fi

#detect_soft
install_neededpackage


if [ "$mailaddr"x = x ] || [ "$mailuser"x = x ] || [ "$mailpass"x = x ] || [ "$mailport"x = x ]     
then                                                                                                              
    echo ""                                                                                                       
    echo -e "${GREEN}You do not indicat a mail server,we will dectect your local mail server!${DCOLOR}"
    echo -e "${GREEN}if you do not have a local mail server,we will installing a new mailserver on localhost ${DCOLOR}"      
    install_postfix                    
    mailaddr="127.0.0.1"
    mailuser="eutadmin"
    mailpass="eutmail"
    mailport=25
    echo ""                                                                                                       
fi

echo ""
echo ""
echo -e "${GREEN}Now create user: $USER...${DCOLOR}"
create_user $USER $PASSWORD

echo -e "${GREEN}Now modify user environment variables...${DCOLOR}"
user_var $USER
mod_sudo $USER $mysqlpath $sufile
echo ""
if [ -f "/etc/rc.local" ]
then
    echo -e "${GREEN}Now start adding mysql server powered up...${DCOLOR}"
    echo "" >>/etc/rc.local
    echo "#Add mysql server powered up..." >>/etc/rc.local
    echo "cd ${mysqlpath};${mysqlpath}bin/mysqld_safe --defaults-file=${mysqlpath}my.cnf -umysql&" >>/etc/rc.local
    echo ""
    echo -e "${GREEN}Add mysql server powered up complete !${DCOLOR}"
    echo -e "${GREEN}Now start adding EUT server powered up...${DCOLOR}"
    echo "" >>/etc/rc.local
    echo "#Add EUT server powered up..." >>/etc/rc.local
    echo "sleep 60" >>/etc/rc.local
    echo "su - EUT -c \"cd /EUT/server/install/monitor;sh EUT.sh start\"" >>/etc/rc.local
    echo -e "${GREEN}Add EUT server powered up complete !${DCOLOR}"
    echo ""
else
    echo -e "${RED}Error,/etc/rc.local file does not exist !${DCOLOR}"
    exit 1
fi
echo -e "${GREEN}Modify user environment variables successfully !${DCOLOR}"
echo ""
create_dir $installdir

echo -e "${GREEN}Now installation third-party dependencies...${DCOLOR}"
install_main
echo -e "${GREEN}All third-party dependencies installation ends !${DCOLOR}"
echo ""

echo ""                                                                                                           
install_supervise
echo ""
echo -e "${GREEN}Now installation EUT applications,Please waitting...${DCOLOR}"
echo ""
install_filesaver
echo ""
tar zxf pgm.tar.gz -C $installdir
tar zxf webapp.tar.gz -C $installdir 
tar zxf webhome.tar.gz -C $installdir
tar zxf store.tar.gz -C $installdir
tar zxf clientupload.tar.gz -C $installdir
tar zxf supervise.tar.gz -C $installdir
replace_configure_file
mod_email
echo -e "${GREEN}Modify the program configuration files ends !${DCOLOR}"
echo ""
echo -e "${GREEN}Now start modify <${basedir}> directory permissions!${DCOLOR}"
chown -R ${USER}.${GROUP} $basedir
echo ""

#add crontab
cat > /tmp/cron.tmp << EOF
1 03 * * * sh ${SOFT_DIR}/server/install/program/smsdelay_deposit.sh 50
1 02 * * * /usr/bin/find ${SOFT_DIR}/internal/plug/httpd-2.2.14/htdocs/screenshot -mtime +5 -exec rm {} \;
1 0 1 * * sh ${SOFT_DIR}/server/install/program/create_month_table.sh 
0 4 * * * sh ${SOFT_DIR}/server/install/program/delete_30days_log.sh
0 0 1 * * sh ${SOFT_DIR}/server/install/program/navi_daily_table.sh
10 4 1 * * sh ${SOFT_DIR}/server/install/program/backup_EUT.sh
30 4 * * 1 sh ${SOFT_DIR}/server/install/program/backup_database.sh
0 * * * * cd /EUT/internal/pgm/ft/ft_01/bin;sh ft_delete.sh >> /dev/null 2>&1
EOF
mv /tmp/cron.tmp /var/spool/cron/${USER}
/bin/chown -R ${USER}:${USER} /var/spool/cron/${USER}
/bin/chmod 600 /var/spool/cron/${USER}

#install mysql database
installmysql
#initialize gd data
initialize_gd_data $IP

#EUTv2.0 add ....

if [ "$DEPLOY" = 0 ]
then
    mytools="${mysqlpath}bin/mysql -S ${mysqlpath}mysql.sock -uroot -psecret"
    corpfile="/EUT/db/mysql7000/initdata/init_corp.sql"
    if [ -f "$corpfile" ]
    then
        while read line                                                       
        do                                                                    
          $mytools -e "$line"                                               
          if [ $? -ne 0 ]                                                   
          then                                                           
              echo -e "${RED}Error,initialize corporation information failed ! ${DCOLOR}"
              exit 1                                                     
          fi                                                                
        done< $corpfile
    else
        echo -e "${RED}Sorry ,Can't find  initialize corporation information file init_corp.sql,Please check your installation source files...${DCOLOR}"
        exit 1
    fi
else
    Mopfile="${installdir}webhome/mop_ims_01/WEB-INF/classes/systemConfig.xml"
    sed -i -r 's#<imsClientVersonIsHide>.*</imsClientVersonIsHide>#<imsClientVersonIsHide>0</imsClientVersonIsHide>#g' $Mopfile
    sed -i -r 's/DEPLOY=0/DEPLOY=1/g' /EUT/server/install/monitor/EUT.sh
fi

#add end

echo -e "${GREEN}Now install and initialize end...${DCOLOR}"
echo ""
echo -e "${GREEN}#############################################################${DCOLOR}"
echo -e "${GREEN}#                                                           #${DCOLOR}"
echo -e "${GREEN}# Installation is complete, installation information below：#${DCOLOR}"
echo -e "${GREEN}#                                                           #${DCOLOR}"
echo -e "${GREEN}#############################################################${DCOLOR}"
echo -e "${GREEN}*************************************************************${DCOLOR}"
echo -e "${GREEN}Thanks,Corporations followed by ...${DCOLOR}"

#EUTv2.0 add ....
if [ "$DEPLOY" = 0 ]
then
    show_corpinfo
else
    show_corpinfo_osp
fi
#add end 

date

echo ""

echo ""
echo -e "${GREEN}*************************************************************${DCOLOR}"
echo ""
echo -e "${GREEN}Thank you for using ${SOFT_NAME} program !${DCOLOR}"
echo -e "${GREEN}Program installation directory for: ${installdir}${DCOLOR}"
echo -e "${GREEN}Create user name: $USER ${DCOLOR}" 
echo -e "${GREEN}User password: $PASSWORD ${DCOLOR}" 
echo -e "${GREEN}This program uses the IP address for: $IP ${DCOLOR}" 

STOP_TIME=`date +%s`
EXPEND_TIME=$(($STOP_TIME - $START_TIME))
echo -e "${GREEN}This program consume time $((${EXPEND_TIME}/60)) minitues and $(($EXPEND_TIME % 60)) seconds ${DCOLOR}" 

rm -f $STAT_FILE
exit 0

#end of script
