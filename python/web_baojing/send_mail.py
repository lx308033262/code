#!/usr/bin/env python
# -*- coding: utf-8 -*-
 

import smtplib,sys
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

if __name__ == '__main__':
        fromaddr = 'baojing@moscoper.com'
        toaddrs = ['308033262@qq.com']
        subject = 'warn mail'

        #content = ''
        content=sys.stdin.read()
        textApart = MIMEText(content)

        #imageFile = '/tmp/code2.png'
        #imageApart = MIMEImage(file(imageFile, 'rb').read(), imageFile.split('.')[-1])
        #imageApart.add_header('Content-Disposition', 'attachment', filename=imageFile.split('/')[-1])

        m = MIMEMultipart()
        m.attach(textApart)
        #m.attach(imageApart)
        m['Subject'] = subject

        server = smtplib.SMTP('mail.moscoper.com')
        server.ehlo()
        server.starttls()

        server.login(fromaddr,'baojing123')
        server.sendmail(fromaddr, toaddrs, m.as_string())
        server.quit()
