#!/bin/bash

export COLLECT_DATE=`date "+%Y/%m/%d %H:%M:%S"`
export HOSTNAME=`hostname`

eval ps -eo user,pid,ppid,pcpu,pmem,rss,args \| grep -v \%CPU \| awk \'\{ process_table\[\$7\] = process_table\[\$7\] + \$6 \} END \{ for \(process in process_table\) print \"${COLLECT_DATE}\;${HOSTNAME}\;\"process\"\;\"process_table\[process\] \}\' >> /home/capacity/rss_stats.txt

