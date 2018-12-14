#!/bin/bash
mytool='/EUT/db/mysql7000/bin/mysql -uroot -psecret -S /EUT/db/mysql7000/mysql.sock'

while read line
do
    $mytool  -N -e "use test;call deluser($line)"
done<mp.txt 
