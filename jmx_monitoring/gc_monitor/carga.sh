#!/bin/bash
##########################################################################################################
## Funcao: Importar metricas de CPU e Memoria (quantidade)
## dos servidores que compoem o tier 1
## Autor: Leandro Pereira Pinto
## Criacao: 29/11/2013
## ALTERACOES:
#  Leandro Pinto        - 03/12/2013
# Descricao
###########################################################################################################

cd 
. ./.profile

# acesso o diretorio padrao
cd /perf_01/coleta/config

# verifico se o script esta em execucao
lock=`ls lock | wc -l`
if [ $lock -ne 0 ]; then
  echo '*** script em execucao ***'
  exit
fi

# crio arquivo para trava
touch lock

# obtendo separador atual
sep=`cat resources/config.properties | grep separador | cut -d"\"" -f2`

# pegando data atual
dataColeta=`date +"%d/%m/%Y %T"`

# removo os arquivos antigos
rm carga.bad carga.csv carga.log coleta_servidores.csv exec_sqlloader_type_erro.log servidores_erro.log carga.ctl

# carrega os servidores do banco de dados
sqlplus -s impmnegocio/intim#2011@caplanp1 << ENDOFSQL

set echo off
set feedback off
set linesize 2000
set pagesize 0
set trimspool on
set head off
set colsep ';'
set pages 0

spool coleta_servidores.csv
  SELECT hostname, tipo_so FROM CAPACITY.TSERVIDOR WHERE usuario IS NOT NULL;
SPOOL OFF;
ENDOFSQL

file=coleta_servidores.csv

OLDIFS=$IFS
IFS=$'\n'
for line in `cat $file`; do

  host=`echo $line | awk '{print $1}'`
  so=`echo $line | awk '{print $2}' | sed 's/;//g'`
  command=""

  if [ $so = "HPU" ]; then
    command="sar -Mu 1 1 | awk 'END {print NR-5}' $sep swapinfo -m | grep memory | awk '{print \$2}'"
  elif [ $so = "LNX" ]; then
    command="cat /proc/cpuinfo  | grep processor | wc -l $sep free -m -t | grep Mem:  | awk '{print \$2}'"
  elif [ $so = "TRU" ]; then
    command="psrinfo | wc -l |tr -d ' ' $sep vmstat -P | grep '^Total Physical Memory' | cut -d'=' -f2 | cut -d'.' -f1 | sed 's/^ *//g'"
  elif [ $so = "SUN" ]; then
    command="/usr/sbin/psrinfo | wc -l | sed 's/^ *//g' $sep /usr/sbin/prtconf | grep Memory | cut -d' ' -f3"
  elif [ $so = "AIX" ]; then
    command="lparstat -i |grep 'Maximum Virtual CPUs' | cut -d':' -f2 | sed 's/^ *//g' $sep lparstat -i |grep 'Maximum Memory' | cut -d':' -f2 | cut -d'MB' -f1 | sed 's/^ *//g'"
  else
    echo "O so $so cadastrado para o servidor $host nao e suportado" >> servidores_erro.log
    continue
  fi

  saida=`java -jar InmetricsSshSftpClient.jar 'ssh' $host $command`

  cpu=`echo $saida | awk '{print $1}'`
  mem=`echo $saida | awk '{print $2}' | sed 's/;//g'`

  if [ $cpu = "Erro" ]; then
    echo $saida >> servidores_erro.log
  else
    echo "$host;$dataColeta;383;$cpu" >> carga.csv
    echo "$host;$dataColeta;384;$mem" >> carga.csv
  fi

done
IFS=$OLDIFS

echo "Processo de coleta finalizado!"
echo "Iniciando processo de persistencia"

# Verifica se o arquivo de carga existe
if [[ ! -e /perf_01/coleta/config/carga.csv ]]; then
   echo "Erro: O arquivo /perf_01/coleta/config/carga.csv nao existe." > /perf_01/coleta/config/exec_sqlloader_type_erro.log
else

   var=/perf_01/coleta/config/carga.csv
   echo "LOAD DATA"                                              > /perf_01/coleta/config/carga.ctl
   echo "INFILE '$var'"                                         >> /perf_01/coleta/config/carga.ctl
   echo "APPEND INTO TABLE CAPACITY.TMINFRA_SERVIDOR"		>> /perf_01/coleta/config/carga.ctl
   echo "FIELDS TERMINATED BY \";\""                            >> /perf_01/coleta/config/carga.ctl
   echo "("                                                     >> /perf_01/coleta/config/carga.ctl
   echo "hostname \"upper(:hostname)\","                        >> /perf_01/coleta/config/carga.ctl
   echo "minfra_data DATE \"dd/mm/yyyy hh24:mi:ss\","           >> /perf_01/coleta/config/carga.ctl
   echo "minfra_id,"                                            >> /perf_01/coleta/config/carga.ctl
   echo "minfra_value)"                                         >> /perf_01/coleta/config/carga.ctl

   sqlldr  impmnegocio/intim#2011 control=/perf_01/coleta/config/carga.ctl  errors=10000000

fi

rm lock

exit 

