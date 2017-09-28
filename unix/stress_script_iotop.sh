#!/bin/bash

V_EXECUTIONS=43200
V_INTERVAL_SECONDS=60
V_OUTPUT_FILE1="log/infra_iotop_log.csv"
V_OUTPUT_FILE2="log/infra_iostat_log.csv"

# Verifica se a backup esta em execucao:
V_ARQUIVO_LOCK=inm_top.lock

# Verificar se o arquivo de lock existe, se sim, aborta a execucao
if [ -a $V_ARQUIVO_LOCK ]; then
        echo "Processo em execucao"
        exit 1
fi

# Cria o arquivo de lock, evita que mais de uma execucao do processo rode ao mesmo tempo
touch $V_ARQUIVO_LOCK

# Grava informacoes iniciais no arquivo de saida
v_servidor=`hostname`
echo "Coleta do servidor: " $v_servidor > $V_OUTPUT_FILE1 >  $V_OUTPUT_FILE2

# Gera loop para coletar processos
i=1
while [[ $i -le $V_EXECUTIONS ]] ;
do

    # Grava o andamento do processo no arquivo de lock
    data=`date '+%d/%m/%Y %T'`
    echo $data - Execucao $i de $V_EXECUTIONS >> $V_ARQUIVO_LOCK

    # Verifica se e a primeira execucao e coloca o cabecalho
    if [ $i -eq 1 ] ; then
      echo "DATE;TID;PRIO;USER;DISK READ;DISK WRITE;SWAPIN;IO>;COMMAND" >> "$V_OUTPUT_FILE1"
      echo "DEVICE;TPS;KB_READ/S;KB_WRTN/S;KB_READ;KB_WRTN"             >> "$V_OUTPUT_FILE2"
    fi

    DATA=`date '+%d/%m/%Y %H:%M:%S'`
    
    sudo iotop -botqqq -n 1 | awk -v date="${DATA}" 'BEGIN{OFS=";"; ORS=""} { gsub( "\\%|[A-Z]/s" ," "); print date,$2,$3,$4,$5,$6,$6,$7,$8,""; for(i=9;i<=NF;i++) {print $i " ";} print "\n";}' >> $V_OUTPUT_FILE1 &
    
         iostat -hNmxz      | awk -v date="${DATA}" 'BEGIN{OFS=";"; ORS=""} { if ( NR > 3  ) {           print date,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11; print "\n";}}'  >> $V_OUTPUT_FILE2 &

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
