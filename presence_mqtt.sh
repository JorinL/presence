#!/bin/bash
# detect Iphone/Android by IP/HOSTNAME and MAC address.
# use MAC address too, to prevent false positives if IP might change
# returns 1 or 0 on mqtt broker for specific name

# number of retries, less is faster, but less accurate
MAXRETRIES=10

# exit immediately if no parameters supplied
if [ $# -lt 2 ]
  then
    echo "UNDEF"
  exit 1
fi

# Set variables
MQTT='192.168.0.8'
USER='fhem'
PW='(fS.(HQbX&48rvsd2y/N'
TOPIC='homeland/haushalt/presence/'
NAME=$1
IP=$(host -4 "${NAME}" | grep -oP '([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}\.([0-9]){1,3}')
MAC=$2
DOMAIN='fritz.box'
COUNT=0


if ping -qc1 ${NAME}.${DOMAIN} &> /dev/null; then
                /usr/bin/mosquitto_pub -h "${MQTT}" -u "$A {USER}" -P "${PW}" -t "${TOPIC}""${NAME}" -q "2" -r -m "1"
                # Next line is for debugging only
                /usr/bin/mosquitto_pub -h "${MQTT}" -u "$A {USER}" -P "${PW}" -t "${TOPIC}""${NAME}/debug" -q "2" -r -m ""${NAME}" detected as present via ping"
                exit 0
                else
                NA=$(host "${NAME}.${DOMAIN}" | grep -oc "not found")
                if [ ${NA} -eq 1 ]; then
                        /usr/bin/mosquitto_pub -h "${MQTT}" -u "${USER}" -P "${PW}" -t "${TOPIC}""${NAME}" -q "2" -r -m "0"
                        # Next line is for debugging only
                        /usr/bin/mosquitto_pub -h "${MQTT}" -u "$A {USER}" -P "${PW}" -t "${TOPIC}""${NAME}/debug" -q "2" -r -m ""${NAME}" detected as non present - no ip behind hostname"
                        exit 0
                        else
                                while [ "${COUNT}" -lt "${MAXRETRIES}" ];
                                        do
                                                hping3 -q -2 -c 10 -p 5353 -i u500000 "${IP}.${DOMAIN}" >/dev/null 2>&1
                                                sleep 1
                                                STATUS=$(nmap "${NAME}.${DOMAIN}" -sU -p 5353 | grep -io "${MAC}")
                                                if [ ${#STATUS} -eq ${#MAC} ]; then
                                                        # exit when phone is detected
                                                        /usr/bin/mosquitto_pub -h "${MQTT}" -u "${USER}" -P "${PW}" -t "${TOPIC}""${NAME}" -q "2" -r -m "1"
                                                        # Next line is for debugging only
                                                        /usr/bin/mosquitto_pub -h "${MQTT}" -u "$A {USER}" -P "${PW}" -t "${TOPIC}""${NAME}/debug" -q "2" -r -m ""${NAME}" detected as present via hping3 and nmap"
                                                        exit 0
                                                fi
                                                ((COUNT++))
                                                sleep .1
                                        done
                fi
fi

# consider away if reached max retries
/usr/bin/mosquitto_pub -h "${MQTT}" -u "${USER}" -P "${PW}" -t "${TOPIC}${NAME}" -q "2" -r -m "0"
/usr/bin/mosquitto_pub -h "${MQTT}" -u "$A {USER}" -P "${PW}" -t "${TOPIC}${NAME}/debug" -q "2" -r -m ""${NAME}" detected as non present - end of detection loop"
