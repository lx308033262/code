#!/usr/bin/env python
# -*- coding: utf-8 -*-
 

import smtplib
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

if __name__ == '__main__':
        #fromaddr = 'zhanghao@izptec.com'
        #toaddrs = ['308033262@qq.com']
        fromaddr = 'zhanghao@moscoper.com'
        toaddrs = ['15010348381@139.com']
        subject = 'smtplib test.'

        content = 'just for test'
	#read the stdin
        #content=sys.stdin.read()

        textApart = MIMEText(content)

        #imageFile = '/tmp/code2.png'
        #imageApart = MIMEImage(file(imageFile, 'rb').read(), imageFile.split('.')[-1])
        #imageApart.add_header('Content-Disposition', 'attachment', filename=imageFile.split('/')[-1])

        m = MIMEMultipart()
        m.attach(textApart)
        #m.attach(imageApart)
        m['Subject'] = subject

        #server = smtplib.SMTP('mail.izptec.com')
        #server.login(fromaddr,'zhanghao141823')
        server = smtplib.SMTP('mail.moscoper.com',587)
        server.ehlo()
        server.starttls()
        server.login(fromaddr,'zhanghao123')
        server.sendmail(fromaddr, toaddrs, m.as_string())
        server.quit()
