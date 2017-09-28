#!/bin/bash

V_EXECUTIONS=43200
V_INTERVAL_SECONDS=60
V_OUTPUT_FILE="infra_ps_log.csv"

V_SERVIDOR="$(hostname)"
v_TIPOSO="$(uname)"

# Verifica se a backup esta em execucao:
V_ARQUIVO_LOCK="inm_collect.lock"

# Verificar se o arquivo de lock existe, se sim, aborta a execucao
if [ -a "$V_ARQUIVO_LOCK" ]; then
        echo "Processo em execucao"
        exit 1
fi

# Cria o arquivo de lock, evita que mais de uma execucao do processo rode ao mesmo tempo
touch "$V_ARQUIVO_LOCK"

# Gera loop para coletar processos
i=1
while [ $i -le $V_EXECUTIONS ]
do

	# Grava o andamento do processo no arquivo de lock
	data="$(date '+%d/%m/%Y %T')"
	echo "$data - Execucao $i de $V_EXECUTIONS" >> "$V_ARQUIVO_LOCK"

	# case feito baseado na contagem de host por tipo ex:
	# grep -i <tipohost(lnx->linux,aix->aix,dig->tru64,sun->solaris) lista-de-hosts-do-excel | wc -l

    # Verifica se e a primeira execucao e coloca o cabecalho
        if [ $i -eq 1 ] ; then
            UNIX95= ps -eo user,pid,ppid,pcpu,vsz,args | awk -v "d=`date '+%d/%m/%Y %T'`" -v "h=$V_SERVIDOR" '{print d ";" h ";"$1";"$2";"$3";"$4";"$5";"$6" "$7" "$8 $9 $10 }' >> $V_OUTPUT_FILE
        else
            UNIX95= ps -eo user,pid,ppid,pcpu,vsz,args | grep -v %CPU | awk -v "d=`date '+%d/%m/%Y %T'`" -v "h=$V_SERVIDOR" '{print d ";" h ";"$1";"$2";"$3";"$4";"$5";"$6" "$7" "$8 $9 $10 }' >> $V_OUTPUT_FILE
        fi

	# Aguarda a proxima execucao
	sleep "$V_INTERVAL_SECONDS"

	# Incrementa o valor de i
	i="$(expr $i + 1)"
done

# Apaga arquivo de lock
rm -f "$V_ARQUIVO_LOCK"
