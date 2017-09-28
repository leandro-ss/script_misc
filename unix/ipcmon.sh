#!/bin/sh
host="$(uname -n)"
echo "host;data;hora;cbytes;qnum;qbytes;pid;comando" >> ipcmon_$host.csv;
while true;
do ipcs -qa |   awk '{if ($9>0 && $9!="CBYTES" && $9!="Jan"){print $9";"$10";"$11";"$13";";}}' | while read l;
  do
    pid="$(echo $l | awk -F\; '{print $4}')"
  	[ "$pid" != "" ] && echo $host";"$(date +"%d/%m/%Y")";"$(date +"%H:%M:%S")";"$l$(ps -p $pid | awk '{ print $4}' | grep -v CMD) >> ipcmon_$host.csv;
  done;
  sleep 300;
done
