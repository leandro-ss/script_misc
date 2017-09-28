#!/bin/sh

V_EXECUTIONS=43200
V_INTERVAL_SECONDS=60
V_OUTPUT_FILE="inodemon.csv"

V_ARQUIVO_LOCK="inodemon.lock"

# Verificar se o arquivo de lock existe, se sim, aborta a execucao
if [ -a $V_ARQUIVO_LOCK ]; then
        echo "Processo em execucao"
        exit 1
fi

# Cria o arquivo de lock, evita que mais de uma execucao do processo rode ao mesmo tempo
touch $V_ARQUIVO_LOCK

v_host="$(uname -n)"

# Gera loop para coletar processos
i=1
while [[ $i -le $V_EXECUTIONS ]] ;
do

    # Grava o andamento do processo no arquivo de lock
    v_date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "$v_date - EXEC $i < $V_EXECUTIONS" >> $V_ARQUIVO_LOCK

    # Verifica se e a primeira execucao e coloca o cabecalho
    if [ $i -eq 1 ] ; then
      echo "HOST;DATE;INODES;IUSED;IFREE;IUSE%;MOUNTED ON" > $V_OUTPUT_FILE
    fi
    top -b -n 1 -H | awk -v date_time=$collect_date_time '{ if(NR > 7) { qtd[$2"."$12"/"$8] = qtd[$2"."$12"/"$8] + 1; cpu[$2"."$12"/"$8] = cpu[$2"."$12"/"$8] + $9; } } END { for(item in qtd) { print date_time";"item";"qtd[item]";"cpu[item] } }' > $V_OUTPUT_FILE


    # Aguarda a proxima execucao
    sleep $V_INTERVAL_SECONDS

    # Incrementa o valor de i
    i=$(expr $i + 1)

done

##########################################
# Finalizacao
##########################################
# Apaga arquivo de lock
rm -f $V_ARQUIVO_LOCK


#!/bin/bash
export x=1
while [[ $x -le 86400 ]] ; do
export collect_date_time=`date '+%d/%m/%Y_%H:%M:%S'`

sleep 1
export x=`expr $x + 1`
done
