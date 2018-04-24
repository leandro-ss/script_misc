#!/bin/bash

for var in "$@"
do

    sqlplus "scapacity01"/"inmtim#0912"@"$var" @get_all.sql 

    # pega lista de logs do host remoto
    for file in $(ls -1 | grep "\.log"); do
        
        new="$(echo $file | sed -e 's/\..*//g')".csv

        awk '{gsub(" *; *",";"); print $0}' $file > "$var"_"$new"
        rm $file
    done
done
