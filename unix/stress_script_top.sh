#!/bin/bash

V_EXECUTIONS=43200
V_INTERVAL_SECONDS=60
V_OUTPUT_FILE="infra_top_log.csv"

# Verifica se a backup esta em execucao:
V_ARQUIVO_LOCK="inm_collect.lock"


# Verificar se o arquivo de lock existe, se sim, aborta a execucao
if [ -a $V_ARQUIVO_LOCK ]; then
        echo "Processo em execucao"
        exit 1
fi

# Cria o arquivo de lock, evita que mais de uma execucao do processo rode ao mesmo tempo
touch $V_ARQUIVO_LOCK

# Grava informacoes iniciais no arquivo de saida
v_servidor=`hostname`
echo "Coleta de top do servidor: " $v_servidor > $V_OUTPUT_FILE

# Gera loop para coletar processos
i=1
while [[ $i -le $V_EXECUTIONS ]] ;
do

    # Grava o andamento do processo no arquivo de lock
    data=`date '+%d/%m/%Y %T'`
    echo $data - Execucao $i de $V_EXECUTIONS >> $V_ARQUIVO_LOCK

    # Verifica se e a primeira execucao e coloca o cabecalho
    if [ $i -eq 1 ] ; then
      echo "DATE;PID;USER;VIRT;RES;SHR;%CPU;%MEM;LOAD;PROCESSES;CPU_TOTAL;MEM_TOTAL_USED;COMMAND" >> "$V_OUTPUT_FILE"
        else
      DATATOP=`date '+%d/%m/%Y %H:%M:%S'`
        top -b -n 1 | awk -v date="${DATATOP}" '{ { if(NR == 1) { load = substr($12,1,length($12)-1) } } { if(NR == 2) { proc = $2 } } { if(NR == 3) { split($5,cpu,"%"); cpu_total = 100 - cpu[1]; } } { if(NR == 4) { mem_used = $4 } } { if(NR > 7) { print date";"$1";"$2";"$5";"$6";"$7";"$9";"$10";"load";"proc";"cpu_total";"mem_used";"$12 } } }' >> $V_OUTPUT_FILE &
        fi

    # Aguarda a proxima execucao
    sleep $V_INTERVAL_SECONDS

    # Incrementa o valor de i
    i=`expr $i + 1`

done

##########################################
# Finalizacao
##########################################
# Apaga arquivo de lock
rm -f $V_ARQUIVO_LOCK
