#!/bin/bash

count=${1:-10}  # defaults to 10 times
delay=${2:-0.5} # defaults to 0.5 seconds
while [ $count -gt 0 ]; do
    for pid in $(/usr/java/jdk1.7.0_79/bin/jcmd | awk '{if($0 !~ /JCmd/)print $1}'); do

        echo "PID = $pid"

        /usr/java/jdk1.7.0_79/bin/jcmd $pid print_threads > print_threads.$pid.$(date +%H%M%S.%N)

        sleep $delay
        let count--
    done
done
