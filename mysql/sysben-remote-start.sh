#!/bin/bash

export mysql_server=192.168.11.205
sshpass -p scaleflux scp -r /root/in-house-debug/sysbench-auto/mysql tcn@${mysql_server}:/tmp/sysbench-auto_mysql
sshpass -p scaleflux ssh tcn@${mysql_server} "pushd /tmp/sysbench-auto_mysql && sh test-run.sh"

sshpass -p scaleflux ssh tcn@${mysql_server} "for i in {1..100};do ps -ef  |grep bin/mysqld | grep -v grep; if [ $? -ne 0 ]; then echo -e "waiting for mysql being ready";sleep 3;fi;done"

echo "mysql server on ${mysql_server} is ready now"
./test-workloads.sh
