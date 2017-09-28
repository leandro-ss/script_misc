#!/bin/ksh 

#set -x

#
#  Objetivo     : Fazer a coleta do console de Weblogic recebido
#  Observações  : O parâmetro esperado é o ID do console
#
#  Histórico de Atualizações
#
#    Data       : 08/01/2013
#    Analista   : Leandro Sampaio
#    Comentário : Criação do Shell
#
# ############################## Início do Script ##############################
#    cd
#    . ./.profile

export ORACLE_SID=CAPLANP1
export ORACLE_HOME=/ora11g/app/product/11.2.0.3/CAPLANP1
export ORA_NLS_LANG=/ora11g/app/product/11.2.0.3/CAPLANP1/nls/data
export PATH=${PATH}:/ora11g/app/product/11.2.0.3/CAPLANP1/bin

export SPEED_DATE="$(date '+%Y%m%d')"
export SPEED_NET_PATH="/perf_01/coleta/speed_interface"
export SYSTEM_LIST_PATH="$SPEED_NET_PATH/system_list"
export LOG_PATH="$SPEED_NET_PATH/log"

MINFRA_ID="662"
FILE_TO_LOAD="net_speed.dat"

cd "$SPEED_NET_PATH"

echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): Mapeamento dos Sistemas [CONSULTA SQL]" >> ${LOG_PATH}/${SPEED_DATE}.log

SQL=`sqlplus -s impmnegocio/intim#2011 <<-sqlEOF
SET PAGES 0;
SET LINES 10000;
SET FEEDBACK OFF;
SET SERVEROUTPUT ON;
DECLARE
CURSOR C_SYSTEM_LIST IS
    SELECT LOWER(TH.TIPO_SO)||' '|| LOWER(TH.HOSTNAME) LINE
    FROM CAPACITY.TSERVIDOR TH
    JOIN CAPACITY.TSISTEMA_SERVIDOR TSS ON TSS.HOSTNAME = TH.HOSTNAME
    JOIN CAPACITY.TSISTEMA TS ON TSS.SISTEMA_ID = TS.SISTEMA_ID
    WHERE 1=1 
    AND TH.ACESSO='S'
    AND TIPO_SO NOT IN ('OUT','WIN')
    AND TIER BETWEEN 1 AND 3
    AND TH.USUARIO IS NOT NULL
    AND TH.STATUS_ID ='A'
    AND TH.ACESSO ='S';
BEGIN
  FOR I IN C_SYSTEM_LIST LOOP
    DBMS_OUTPUT.PUT_LINE(I.LINE);
  END LOOP;
  EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO');
END;
/
`

    if [[ ${SQL} != "ERRO" ]] ; then
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): sqlplus [CONSULTA SQL EFETUADA]" >> ${LOG_PATH}/${SPEED_DATE}.log
    else
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): sqlplus [ERRO NA CONSULTA SQL ]" >> ${LOG_PATH}/${SPEED_DATE}.log
        exit 1
    fi

    mkdir "$SYSTEM_LIST_PATH" 2> /dev/null
    RETORNO_SHELL=$?

    if [[ ${RETORNO_SHELL} -eq 0 ]] ; then
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): mkdir [BASE DO MAPEAMENTO DOS HOSTS EFETUADO]" >> ${LOG_PATH}/${SPEED_DATE}.log
    else
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): mkdir [ERRO NO MAPEAMENTO DOS HOSTS]" >> ${LOG_PATH}/${SPEED_DATE}.log
        exit 1
    fi

    echo "$SQL" |while read line; do 

        type_OS=$(echo $line | awk '{print $1}')
        mkdir "$SYSTEM_LIST_PATH/$type_OS" 2> /dev/null

        hostname=$(echo $line | awk '{print $2}')
        touch "$SYSTEM_LIST_PATH/$type_OS/$hostname"
    done

echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): Mapeamento dos Sistemas [MAPEAMENTO EFETUADO]" >> ${LOG_PATH}/${SPEED_DATE}.log

    for type in $(ls -1 $SYSTEM_LIST_PATH); do 

        for host in $(ls -1 $SYSTEM_LIST_PATH/$type | egrep  -v ^$type); do

            ksh script_net_speed_get.sh "$SYSTEM_LIST_PATH" "$type" "$host" &
                
            echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): script_net_speed_get.sh [ $type - $host ]" >> ${LOG_PATH}/${SPEED_DATE}.log
            
            if [ `ps -ef| grep script_net_speed_get | wc -l` -ge 6 ]; then
                echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): sleep [LIMIT PARALLEL PROCESS - WAITING]" >> ${LOG_PATH}/${SPEED_DATE}.log
                sleep 10; continue
            fi
        done
    done
    

    while [ `ps -ef| grep script_net_speed_get | wc -l` -ge 2 ]
    do
        sleep 20
    done

    awk -v date="$SPEED_DATE" -v id="$MINFRA_ID" '{file=FILENAME; sub(".*/","",file); print date,id,file,$0}' "$SYSTEM_LIST_PATH"/*/* > "$FILE_TO_LOAD"
    RETORNO_SHELL=$?

    if [[ ${RETORNO_SHELL} -eq 0 ]] ; then
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): awk [SUMARIZACAO DO DADO EFETUADA]" >> ${LOG_PATH}/${SPEED_DATE}.log
    else
        echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): awk [ERRO DURANTE A EXECUCAO]" >> ${LOG_PATH}/${SPEED_DATE}.log
        exit 1
    fi

    echo " LOAD DATA                                                  " > mapping.ctl
    echo " INFILE '$FILE_TO_LOAD'                                     " >> mapping.ctl
    echo " APPEND                                                     " >> mapping.ctl
    echo " INTO TABLE CAPACITY.TMINFRA_SERVIDOR                       " >> mapping.ctl
    echo " FIELDS TERMINATED BY ' '                                   " >> mapping.ctl
    echo " TRAILING NULLCOLS                                          " >> mapping.ctl
    echo "       (                                                    " >> mapping.ctl
    echo "        MINFRA_DATA   \"TO_DATE(:MINFRA_DATA, 'yyyymmdd')\"," >> mapping.ctl
    echo "        MINFRA_ID                                          ," >> mapping.ctl
    echo "        HOSTNAME                                           ," >> mapping.ctl
    echo "        MINFRA_VALUE                                        " >> mapping.ctl
    echo "       )                                                    " >> mapping.ctl

    sqlldr impmnegocio/intim#2011@CAPLANP1 control=mapping.ctl direct=true bindsize=10485760 readsize=10485760 errors=1000000
    RETORNO_SHELL=$?

    #if [[ ${RETORNO_SHELL} -eq 0 ]] ; then
    #    echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): sqlldr [LOAD EFETUADO]" >> ${LOG_PATH}/${SPEED_DATE}.log
    #else
    #    echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): sqlldr [ERRO DURANTE A EXECUCAO]" >> ${LOG_PATH}/${SPEED_DATE}.log
    #    exit 1
    #fi

    rm -R "$SYSTEM_LIST_PATH"
    rm "$FILE_TO_LOAD"
    
echo "["`date '+%Y-%m-%d %H:%M:%S'`"] (    script_net_speed_start.sh): script_net_speed_start.sh [FINALIZANDO SCRIPT SEM ERROS]" >> ${LOG_PATH}/${SPEED_DATE}.log

################################## Fim do Script ###############################
