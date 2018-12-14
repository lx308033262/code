#!/bin/bash
web_sites='www.dongdao.net'
mail_script='./send_mail.py'
for web_site in $web_sites
do
return_code=`curl -o /dev/null -s  -w %{http_code} http://$web_site`
if [ $return_code -ne 200 ];then
	echo "$web_site http status is not 200,please check!"|$mail_script
#for debug code
#else
#	echo "$web_site http status is ok!"|$mail_script
fi
done
