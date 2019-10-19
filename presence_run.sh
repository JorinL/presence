#!/bin/bash
function jumpto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

start=${1:-"start"}

jumpto $start

start:
cd /etc/rancherVolume/fhem/scripts
#no capital letters inside the MAC!!
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
./presence_mqtt.sh ExamplePhone 00:00:00:00:00:00 &
jumpto timer 


timer:
sleep 300
jumpto start
