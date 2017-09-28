#!/bin/ksh

    dest="$1"
    type="$2"
    host="$3"

    if [ $type ==  "lnx" ]; then

        result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for j in \$(netstat -i | awk '{if (NR > 1) print \$1}' );do for i in \$( ls -1 /proc/net/bonding); do if [ \$i == \$j ];then cat /proc/net/bonding/\"\$i\"; fi; done; done" | awk 'BEGIN{count=0;values[0];bck=0;} /[Ss]peed|[Dd]uplex/{if ($0~/[Bb]ackup/){bck+=1;} else if ($0 ~ /[Ss]peed/){gsub("[^[:digit:]]",""); if($0 ~ /[0-9]+/){values[count] = $0;count++}} } END {asort(values);if(values[1] < 1){print "erro"} else { if(bck!=0){total=0;for(a in values){total+=values[a];} print total;} else { print values[count];}}}')
        
        if [ $result ==  "erro" ]; then 

            result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for j in \$(netstat -i | awk '{if (NR > 1) print \$1}' );do for i in \$(find /sys/class/net/\$j/speed | grep -v lo); do cat \"\$i\"; done; done" | awk 'BEGIN{values[0];count=0;}{ if($0 !~ "") {values[count] = $0;count++;}} END {asort(values);if(values[count] !~ /[0-9]+/) {print "erro"} else { print values[count];}}')
        
        fi
        if [ $result ==  "erro" ]; then 

            result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "dmesg | grep -i eth | grep -i [Uu]p" | awk 'BEGIN{values[1];} { a=substr($0, match( $0,/[Uu]p/, arr)); match(a,/ Mbps| Gbps/, arr); gsub("[^[:digit:]]","",a); if(arr[0] == " Gbps") values[NR] = a*1000; else if(arr[0] == " Mbps") values[NR] = a; else values[NR] = "erro";} END{asort(values); print values[1];}')
            
        fi
        if [ $result ==  "erro" ]; then 

            result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "/sbin/lspci | grep -i ethernet" | awk 'BEGIN{values[1];} /.+/ {if($0 ~ /VMware/) {values[NR] = 10000} else { match($0,/[01]+.Mbps|[01]+.Gbps|[01]+.Gigabit|[01]+.Megabit/, arr); if(arr[0]~"Gbps" || arr[0]~"Gigabit"){ gsub("[^[:digit:]]","",arr[0]); values[NR] = arr[0]*1000;} else if(arr[0] ~ "Mbps" || arr[0] ~ "Megabit" ) {gsub("[^[:digit:]]","",arr[0]); values[NR] = arr[0];} else values[NR] = "erro";}} END {asort(values); print values[1];}')
        fi

        echo "$result" >> "$dest/$type/$host"
        
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_get.sh): ["${host}"value "${result}"]" >> log/${SPEED_DATE}.log
    
        elif [ "$type" ==  "aix" ]; then

        result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "lscfg | grep \" ent\"" | awk 'BEGIN{values[1];} {if ($0 ~ "Virtual I/O"){values[NR] =  1000} else { if (match( $0,/[0-1]+.?Base/, arr) != 0) {gsub("[[:alpha:]]| ","",arr[0]); values[NR] = arr[0]} else values[NR] = "erro"; }} END{asort(values); print values[1];}')

        if [ $result ==  "erro" ]; then 

            result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for en in \`netstat -i | grep en | awk '{print \$1}' | sort -u\`;do entstat -d \$en | egrep -i \"media speed running|backup adapter|virtual i/o\"; done " | awk 'BEGIN{values[0];bkp=0;vrt=0;} {if ($0~"Backup") bkp=1; if($0~"Virtual I/O") vrt=1; else { if (match($0,/[0-1]+.?Mbps/, arr) != 0) {gsub("[[:alpha:]]| ","",arr[0]); values[NR] = arr[0]} else values[NR] = "erro"; }} END{asort(values); if(vrt==0) {if(bkp==0) {total=0;for(a in values) total+=values[a]; print total;} else { print values[1];}} else print 1000;}')
        fi

        echo "$result" >> "$dest/$type/$host"
        
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_get.sh): ["${host}"value "${result}"]" >> log/${SPEED_DATE}.log

    elif [ "$type" ==  "hpu" ]; then
    
        result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for i in \$(eval /usr/sbin/lanscan -q | awk '{len=split(\$0,arr,\" \"); if(len > 1){for(i in arr)print arr[i];}}');do echo \$(eval /usr/sbin/lanadmin -x speed \$i 2> /dev/null) | awk '{printf \$0\" \"} END { print}';done" | awk 'BEGIN{values[0]}{if($0 !~ /The link is down/){gsub("[^0-9]","");values[NR]=$0}}END{asort(values);if(values[1] <= 0){print "erro"} else { if(full!=0){total=0;for(a in values) total+=values[a]; print total;} else { print values[1];}}}') 

        if [ $result ==  "erro" ]; then 

            result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for i in \$(eval /usr/sbin/lanscan -q | awk '{split(\$0,arr,\" \"); for(i in arr){print arr[i];}}');do echo \$(eval /usr/sbin/lanadmin -x speed \$i 2> /dev/null) | awk '{printf \$0\" \"}END{ print}'; done" | awk 'BEGIN{value=0}{if($0 !~ /The link is down/){gsub("[^0-9]","");if(value< $0)value= $0}}END{print value}')
        fi

        echo "$result" >> "$dest/$type/$host"

        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_get.sh): ["${host}"value "${result}"]" >> log/${SPEED_DATE}.log

    elif [ "$type" ==  "sun" ]; then

        result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for i in \`/usr/bin/netstat -i | awk '{if(NR > 1 )print \$1}'\`;do /usr/bin/kstat -p | grep \$i | grep ifspeed; done" |  awk 'BEGIN{value=0}{if($2 ~ /[0-9]+/ && value < $2)value= $2} END {print value/1000000}')

        echo "$result" >> "$dest/$type/$host"

        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_get.sh): ["${host}"value "${result}"]" >> log/${SPEED_DATE}.log

    elif [ "$type" ==  "tru" ]; then

        #result=$(timeout 60s java -XX:+UseLargePages -Xms16m -Xmx16m -jar /perf_01/coleta/config/console_ssh.jar ssh $host "for i in `/usr/bin/netstat -i | awk '{if(NR > 1 )print \$1}'`;do /usr/bin/kstat -p | grep \$i | grep ifspeed; done" |  awk 'BEGIN{value=0}{gsub("^[[:graph:]]* ","");if(value< $0)value= $0} END {print value/10000}')

        #echo "$result" >> "$dest/$type/$host"

        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_get.sh): ["${host}"value "${result}"]" >> log/${SPEED_DATE}.log
    fi

