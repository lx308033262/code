#!/bin/bash

#set ulimit
if ! grep -q "ulimit -SHn 102400" /etc/rc.local;then
    echo "ulimit -SHn 102400" >> /etc/rc.local
fi

if ! grep -q "add limit" /etc/security/limits.conf;then
cat >> /etc/security/limits.conf << EOF
#########add limit###################
*           soft   nofile       200000
*           hard   nofile       200000
EOF
echo "ulimit -SHn 102400" >> /etc/rc.local
fi

#disable ipv6
cat << EOF
+---------------------------------+
| === Welcome to Disable IPV6 === |
+---------------------------------+
EOF
if ! grep -q "Disable IPV6" /etc/modprobe.conf;then
    echo "#####isable IPV6#####" >> /etc/modprobe.conf
    echo "alias net-pf-10 off" >> /etc/modprobe.conf
    echo "alias ipv6 off" >> /etc/modprobe.conf
fi
/sbin/chkconfig --level 35 ip6tables off
echo "ipv6 is disabled!"

#disable selinux
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
echo "selinux is disabled,you must reboot!"

#vim
sed -i "8 s/^/alias vi=vim/" /root/.bashrc
if ! grep -q "syntax on" /root/.vimrc;then
echo 'syntax on' >> /root/.vimrc
fi

#zh_cn
#sed -i -e 's/^LANG=.*/LANG=zh_CN.UTF-8/' /etc/sysconfig/i18n


#init_ssh
ssh_cf="/etc/ssh/sshd_config" 
sed -i "s/#UseDNS yes/UseDNS no/" $ssh_cf
#client
service sshd restart
echo "ssh is init is ok.............."


#tunoff services
#--------------------------------------------------------------------------------
cat << EOF
+--------------------------------------------------------------+
|         === Welcome to Tunoff services ===                   |
+--------------------------------------------------------------+
EOF
#---------------------------------------------------------------------------------
for i in `ls /etc/rc3.d/S*|grep -v 'local'`
do
    CURSRV=`echo $i|cut -c 15-`
    echo $CURSRV
    case $CURSRV in
        crond | network | sshd | rsyslog | salt-minion | zabbix-agent )
        echo "Base services, Skip!"
        ;;
        *)
        echo "change $CURSRV to off"
        chkconfig --level 235 $CURSRV off
        service $CURSRV stop
        ;;
    esac
done
echo "service is init is ok.............."

if ! grep -q "add kernel optimize" /etc/sysctl.conf;then
cat >> /etc/sysctl.conf << EOF
#######add kernel optimize###########
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
#net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 0
net.ipv4.ip_local_port_range="1024 65530"
net.ipv4.tcp_fin_timeout = 3
net.ipv4.ip_nonlocal_bind=1
EOF
fi

/sbin/sysctl -p > /dev/null 2>&1
echo "sysctl set OK!!"
