#!/bin/bash
# detect Iphone/Android by IP/HOSTNAME and MAC address.
# uses MAC address too, to prevent false positives if IP might change
# returns 1 or 0 on mqtt broker for specific name




# number of retries, less is faster, but less accurate
PREMAXRETRIES=8
MAXRETRIES=8

# exit immediately if no parameters supplied
if [ $# -lt 2 ]
  then
    echo "UNDEF"
  exit 1
fi

# Set variables
MQTT='MQTTSERVER'
USER='USER'
PW='PASSWORD'
TOPIC='your/specific/topic/'
NAME=$1
IP=`echo $1 | grep -oP '([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}'`
HOST=`host -4 $1 | grep -oP '([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}'`
MAC=$2
COUNT=0
PRECOUNT=0

if [ -z "$IP" ]; then 
 IP=${HOST}
 if [ -z "$IP" ]; then
 /usr/bin/mosquitto_pub -h ${MQTT} -u ${USER} -P ${PW} -t ${TOPIC}${NAME}" -q "2" -r -m "0"
 exit 0
 fi
fi

while [ ${PRECOUNT} -lt ${PREMAXRETRIES} ];
do
 PRECHECK=`sudo arp-scan -q -g ${IP} | grep -o "${MAC}"`
 if [ ${#PRECHECK} -eq ${#MAC} ]; then
   # exit when phone is detected
   /usr/bin/mosquitto_pub -h ${MQTT} -u ${USER} -P ${PW} -t ${TOPIC}${NAME}" -q "2" -r -m "1"
   exit 0
   fi
   ((PRECOUNT++))
done


while [ ${COUNT} -lt ${MAXRETRIES} ];
do
  # Change dev and eth0 if needed
  #   sudo ip neigh flush dev eth0 ${IP}
  sudo hping3 -q -2 -c 10 -p 5353 -i u1 ${IP} >/dev/null 2>&1
  #sudo hping3 -q -2 -c 10 -p 5353 -i u1 ${IP}
  sleep .1
  # Only arp specific device, grep for a mac-address
  STATUS=`sudo arp-scan -q -g ${IP} | grep -o "${MAC}"`

  if [ ${#STATUS} -eq ${#MAC} ]; then
     # exit when phone is detected
     /usr/bin/mosquitto_pub -h ${MQTT} -u ${USER} -P ${PW} -t ${TOPIC}${NAME}" -q "2" -r -m "1"
    exit 0
  fi
  ((COUNT++))
  sleep .1
done
# consider away if reached max retries
/usr/bin/mosquitto_pub -h ${MQTT} -u ${USER} -P ${PW} -t ${TOPIC}${NAME}" -q "2" -r -m "0"
