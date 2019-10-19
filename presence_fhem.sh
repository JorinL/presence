#!/bin/bash
# detect Iphone/Android by IP/HOSTNAME and MAC address.
# returns 1 or 0 from mqtt broker to fhem


# exit immediately if no parameters supplied
if [ $# -lt 1 ]
  then
    echo "UNDEF"
  exit 1
fi

# Set variables
NAME=$1

#MQTT without auth
RESULT=`/usr/bin/mosquitto_sub -h MQTTSERVER -t "your/specific/topic/${NAME}" -C 1`
#MQTT With auth:
#RESULT=`/usr/bin/mosquitto_sub -h MQTTSERVER -u USER -P "PASSWORD" -t "your/specific/topic/${NAME}" -C 1`
#RESULT='1'
#echo "${RESULT}"
if [ "${RESULT}" == "1" ]; then
        echo "1"
        exit 0
else
        echo "0"
        exit 0
fi
done
