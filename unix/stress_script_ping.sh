#!/bin/sh
V_EXECUTIONS=1680
V_INTERVAL_SECONDS=240

HOST=SNELNX138

i=1; while [ $i -le $V_EXECUTIONS ]
do
        LOG_DATE=`date '+%d/%m/%Y %H:%M:%S'`

        j=1; while [ $j -le 60 ]
        do
                ping -c1 ${HOST} | grep icmp | awk -v "data=${LOG_DATE}" '{ print data" "$0 }' >> ping.log

                j="$(expr $j + 1)"
        done

        ping  -c60 ${HOST} | grep icmp | awk -v "data=${LOG_DATE}" '{ print data" "$0 }' >> ping.log

        i="$(expr $i + 1)"

        sleep "$V_INTERVAL_SECONDS"
done
