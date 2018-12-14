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

install_jdk $1
