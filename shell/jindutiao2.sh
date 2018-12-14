#!/bin/bash

trap 'kill $BG_PID;echo;exit' 1 2 3 15

function rotate

{

    INTERVAL=0.1

    TCOUNT="0"

    stty -echo >/dev/null 2>&1

    while :

    do

        TCOUNT=`expr $TCOUNT + 1`

        case $TCOUNT in

            "1") echo -e '-'"\b\c"

            sleep $INTERVAL

            ;;

            "2") echo -e '\'"\b\c"

            sleep $INTERVAL

            ;;

            "3") echo -e "|\b\c"

            sleep $INTERVAL

            ;;

            "4") echo -e "/\b\c"

            sleep $INTERVAL

            ;;

            *) TCOUNT="0" ;;

        esac

    done

    stty echo

}

rotate &

ROTATE_PID=$!

#

# #开始程序主体，本例中执行休眠10秒

# #注意必要时使用 >/dev/null 2>&1关闭输出和错误回显，避免破坏显示

sleep 10

#

# #程序结尾注意kill dots，否则dots会一直执行；清除多余字符

kill -9 $ROTATE_PID

echo -e "\b\b"
