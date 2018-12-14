#!/bin/bash
SWITCH="00000000"
EXT="00000"

version()
{
        echo -e "Install asterisk program, version: 1.3"
        echo "update date: 2013.04.10"
        echo -e "Author:hechuanning@feinno.com"
}

usage()
{
        version
        echo ""
        echo "USAGE:$0"
        echo "        [-h|--help]                      Display help information"
        echo "        [-v|-V|--version]                Display the version number"
        echo "        [-s]                             Enter the company's switchboard number,Cannot have space between the parameters and switchboard number, otherwise                                                       the program won't run! Example: sh insll.sh -s57973528 -e80096"
        echo "        [-e]                             Enter the EUT system USES the extension number,Cannot have space between the parameters and switchboard number, o                                                       therwise the program won't run! Example: sh insll.sh -s57973528 -e80096"
        echo ""
        echo "NOTICE:"
        echo "       The install script will help install asterisk program."
        echo "..."
        echo ""
        echo "Example: sh insll.sh -s57973528 -e80096 "
        echo ""
}

TEMP=`getopt -o hvVs::e:: --long help,version -- "$@" 2>/dev/null`

if [ $? != 0 ]
then
        echo -e "${RED}INSTALL_ERROR: wrong option!${DCOLOR}"
        echo ""
        usage
        exit 1
fi

eval set -- "$TEMP"

while true
do
   if [ -z "$1" ]
   then
       break 1
   fi

   case "$1" in
        -h|--help) usage; exit 0;;
        -v|-V|--version) version; exit 0;;
        -s) if [ "$2"x != x ];then SWITCH=$2;fi;shift 2;;
        -e) if [ "$2"x != x ];then EXT=$2;fi;shift 2;;
        --) shift;;
        *) echo -e "${RED}INSTALL_ERROR: wrong option!${DCOLOR}"; echo ""; usage; exit 1 ;;
        esac
done


SOFT_NAME="ippbx_complete.tar.gz"
BIT=`getconf LONG_BIT`
C_DIR=`pwd`

detect_stat()
{
if [ $? -ne 0 ];then
    echo "$FUNCNAME install fail"
    exit 1
fi
}


install_rpm()
{
 cd $C_DIR/ippbx
 if [ $BIT -eq 32 ];then
    RPM_DIR=rpm_32
 elif  [ $BIT -eq 64 ];then
    RPM_DIR=rpm_64
 else
    echo "unknow system bit"
    exit 1
 fi
 cd $RPM_DIR
 rpm -ivh *.rpm
}


install_libpri()
{
cd $C_DIR/ippbx
libpri=libpri-1.4.12.tar.gz
tar xzf $libpri
cd ${libpri%.tar.gz}
make
make install
detect_stat
}

install_dahdi()
{
cd $C_DIR/ippbx
dahdi=dahdi-linux-complete-2.6.1+2.6.1.tar.gz
tar xzf $dahdi
cd ${dahdi%.tar.gz}
make
make install
make config
detect_stat
}


install_asterisk()
{
cd $C_DIR/ippbx
aster=asterisk-1.8.15.1_20121225_1005.zip
unzip $aster
cd asterisk-1.8.15.1
chmod +x -R *
./configure
rm -rf menuselect.makeopts
make
make install
make config
detect_stat
cp -rp sounds/* /var/lib/asterisk/sounds/
}

cp_ast_config()
{ 
cd $C_DIR/ippbx
tar zxvf asterisk_config.tar.gz -C /etc/asterisk/
}

replace_mysql()
{
mysql_conf="/etc/asterisk/res_config_mysql.conf"
sed -i '/^ dbhost/s/.*/ dbhost = 127.0.0.1/g' $mysql_conf
sed -i '/^ dbname/s/.*/ dbname = asterisk/g' $mysql_conf
sed -i '/^ dbuser/s/.*/ dbuser = pgm/g' $mysql_conf
sed -i '/^ dbpass/s/.*/ dbpass = pgmfetion/g' $mysql_conf
sed -i '/^ dbport/s/.*/ dbport = 7000/g' $mysql_conf
}

replace_sip()
{
sip_conf="/etc/asterisk/sip.conf"
if [ "$NAT" == "True" ];then
    sed -i '/externip/s/.*/externip='$NAT_IP'/g' $sip_conf
    sed -i '/nat/s/.*/nat=yes/g' $sip_conf
else
    sed -i '/externip/s/.*/externip='$IP'/g' $sip_conf
    sed -i '/nat/s/.*/nat=no/g' $sip_conf
fi
}

replace_ss()
{
 SS_FILE=/EUT/internal/pgm/ss/ss_01/config/config.system
 sed -i '/<SERVER NAME="SBC">/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $SS_FILE
 sed -i '/<SERVER NAME="SBC-FEINNO">/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/127.0.0.1/g' $SS_FILE
}

#replace_mop()
#{
# MOP_FILE=/EUT/internal/webhome/mop_ims_01/WEB-INF/classes/systemConfig.xml
# 
#}

#需要两个参数 $1为总机号码 $2为分机号码
replace_ippbx()
{
 IPPBX_FILE=/EUT/internal/webhome/ippbx_ims_01/WEB-INF/classes/systemConfig.xml
 sed -i 's@<CorpSwitchBoard>[0-9]*</CorpSwitchBoard>@<CorpSwitchBoard>'$1'</CorpSwitchBoard>@g' $IPPBX_FILE
 sed -i 's@<CorpExtension>[0-9]*</CorpExtension>@<CorpExtension>'$2'</CorpExtension>@g' $IPPBX_FILE
 sed -i 's@<AsteriskRootName>.*</AsteriskRootName>@<AsteriskRootName>EUT</AsteriskRootName>@g' $IPPBX_FILE
 sed -i 's@<AsteriskRootPasswd>.*</AsteriskRootPasswd>@<AsteriskRootPasswd>EUTadmin</AsteriskRootPasswd>@g' $IPPBX_FILE
 chown -R EUT.EUT /etc/asterisk
 #chown -R EUT.EUT /var/lib/asterisk/sounds/cn/custom/
}

id EUT >/dev/null 2>&1 ||  exit 1

tar --remove-files -xzf $SOFT_NAME

if ! grep '/etc/init.d/asterisk' /etc/sudoers ;then
    sed -i '$a\EUT     ALL=(root)      NOPASSWD:/etc/init.d/dahdi,NOPASSWD:/etc/init.d/asterisk,NOPASSWD:/usr/sbin/dahdi_scan' /etc/sudoers
fi

install_rpm
install_libpri
install_dahdi
install_asterisk
cp_ast_config
replace_mysql
replace_sip
replace_ippbx $SWITCH $EXT

/etc/init.d/dahdi start
dahdi_genconf 
/etc/init.d/asterisk start
