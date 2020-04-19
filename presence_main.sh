#!/bin/bash
/bin/echo -e "nameserver 192.168.0.1\n" > /etc/resolv.conf
cd /presence
while true
do
./presence_run.sh &
sleep 300
done
