#!/bin/bash
echo `date +%F:%T` "begin" >time
mytool='mysql -h172.21.1.78 -ujabber -pzhoudaidba'

cd `date +%F`

read_file() 
{
    while read line
    do

        #for i in `seq 0 9`
        #do
        #$mytool -N -e "select eid,userid,mp,status from ginf_db.ginf_users_0${i} where mp = $line and status = 0 and status !=1" >> no.txt
        #done
        #if ! grep "$line" no.txt;then
            for i in `seq 0 9`
            do
                $mytool -N -e "select eid,userid,mp,status from ginf_db.ginf_users_0${i} where mp = $line and status = 1" >> $1_yes.txt
            done
            if ! grep "$line" $1_yes.txt;then
		echo "$line" >> $1_no.txt
	    fi
        #    if ! grep "$line" yes.txt;then
        #        for i in `seq 0 9`
         #       do
           #         $mytool -N -e "select eid,userid,mp,status from ginf_db.ginf_users_0${i} where mp = $line" >> unknow.txt
          #      done
	#	if ! grep "$line" unknow.txt;then
	#	    echo "$line" >> norecord.txt
	#	fi
	 #   fi
#        fi

    done<$1
}

for file in `ls *.0*`
do
    awk -F'|' '{print $1}' $file > $file.new
    mv $file.new $file
    read_file $file &
done     
wait
check_result()
{
    wc -l *.00* |awk '{a=$1;getline;b=$1;getline;c=$1;if(a!=b+c)print $2}'|grep -v total > check.result
    wc -l check.result |awk '{if($1==0)print "rm ",$2}'|sh
}
check_result
cat *_no.txt > sum_no.txt
cat *_yes.txt > sum_yes.txt
tar czf sum.tar.gz sum_no.txt sum_yes.txt
echo `date +%F:%T` "end"  >> time
