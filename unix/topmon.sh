#!/bin/sh

V_EXECUTIONS=43200
V_INTERVAL_SECONDS=60
V_OUTPUT_FILE="topmon.csv"

V_ARQUIVO_LOCK="topmon.lock"

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
      echo "HOST;DATE;PID;USER;VIRT;RES;SHR;%CPU;%MEM;LOAD;PROCESSES;CPU_TOTAL;MEM_TOTAL_USED;COMMAND" > $V_OUTPUT_FILE
    fi
    
    top -b -n 1 | awk -v host="${v_host}" -v date="${v_date}" '{ { if(NR == 1) { load = substr($12,1,length($12)-1) } } { if(NR == 2) { proc = $2 } } { if(NR == 3) { split($5,cpu,"%"); cpu_total = 100 - cpu[1]; } } { if(NR == 4) { mem_used = $4 } } { if(NR > 7) { print host";"date";"$1";"$2";"$5";"$6";"$7";"$9";"$10";"load";"proc";"cpu_total";"mem_used";"$12 } } }' >> $V_OUTPUT_FILE &

    # Aguarda a proxima execucao
    sleep $V_INTERVAL_SECONDS

    # Incrementa o valor de i
    i=$(expr $i + 1)

done

