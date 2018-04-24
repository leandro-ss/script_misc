#!/bin/sh

for filename in `ls -1 *.log`
do

ano=`date +"%Y"`
mes=`date +"%m"`

# obter o último timestamp gerado
vlast_time=`tail -1 $filename | awk '{gsub(":","",$1); print $1}'`

# converter a última data de alteração do arquivo para timestamp
varq_date=`ls -ltr $filename | awk -v ano=$ano -v mes=$mes '{print mktime(ano" "mes" "$7" "substr($8,1,2)" "substr($8,4,2)" 00")}'`

# obter a data inicial do arquivo no formato timestamp
vconstante=`ls -ltr $filename | awk -v ano=$ano -v mes=$mes -v last=$vlast_time '{print mktime(ano" "mes" "$7" "substr($8,1,2)" "substr($8,4,2)" 00") - last}'`

echo "data do arquivo "$varq_date "  ùltimo timestamp " $vlast_time " constante gerada "$vconstante "arquivo " $filename

# agrupar etapas que causam stop-the-world
awk -v file=$filename -v constante=$vconstante '{gsub(":","",$1); if ($4 ~ /CMS-initial-mark/)
         print strftime("%Y-%m-%d %H:%M:%S",constante+$1)";"substr(file,4,13)";"substr($4,0,16)";"$7;
        else if (($2" "$3" "$5) ~ /Full GC \[CMS:/)
         print strftime("%Y-%m-%d %H:%M:%S",constante+$1)";"substr(file,4,13)";"substr($2,2,5)" "$3";"$7";"$9;
        else if ($19 ~ /CMS-remark/)
         print strftime("%Y-%m-%d %H:%M:%S",constante+$1)";"substr(file,4,13)";"substr($19,1,10)";"$22;
        else if (($2" "$3" "$5" "$6" "$7" "$8) ~ /Full GC \[CMS \(concurrent mode failure\)/)
         print strftime("%Y-%m-%d %H:%M:%S",constante+$1)";"substr(file,4,13)";"substr($2,2,5)" "$3" "substr($8,1,7)";"$10";"$12;
         }' $filename > gc_cms.txt

done
