#!/bin/bash

#!/bin/bash
setup_JDK() {
    expect << EXP
    spawn ./jdk-6u7-linux-i586.bin
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

     expect eof
     EXP
         }
setup_JDK
