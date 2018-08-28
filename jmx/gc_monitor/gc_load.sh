#!/usr/bin/ksh

set -x

echo "########################## `date '+%Y-%m-%d %T'` $REMOTE_HOST: Iniciando variavies $SUFFIX"

# pega no REMOTE_HOST pela linha de comando
REMOTE_HOST="$1"

# diretorio remoto de onde extrair os dados do DSF
REMOTE_PATH="$2"

# prefixo logs http para o grep
PREFIX="$3"

# sufixo para os arquivos de saida
SUFFIX="$4"

# ID do sistema
SYSTEM_ID="$5"

# ID do sistema
CONSOLE_ID="$6"

# ALGORITMO APLICADO SERIAL / CMS / PARALLEL
ALGORITHM_GC="$7"

# Armazena o caminho para o script inicial
HOME_PATH="$(pwd)"

# pega o hostname remoto
REMOTE_HOST="$(echo $REMOTE_HOST | cut -d'.' -f1 | tr A-Z a-z)"

# diretorio local do sistema
LOCAL_PATH="/perf_01/coleta/ext_table/sistemas/$SYSTEM_ID"

# criando diretorio para o servidor atual
DIR_HOST="${LOCAL_PATH}/${REMOTE_HOST}"

# verifica se o diretÃ³rio existe
if [ ! -d "$LOCAL_PATH" ]; then
  echo "criei o diretÃ³rio $LOCAL_PATH"
  mkdir $LOCAL_PATH
fi

# verifica se o diretÃ³rio existe
if [ ! -d "$DIR_HOST" ]; then
  echo "criei o diretÃ³rio $DIR_HOST"
  mkdir $DIR_HOST
fi

# arquivos de controle do ponto leitura
FLE_CNT_ANT="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}_ANT.cnt"
FLE_CNT_ATL="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}_ATL.cnt"

# arquivo de controle do loader
ACL_LOG="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}.log"
ACL_BAD="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}.bad"

# arquivo de controle do parser
FLE_AWK="${HOME_PATH}/${ALGORITHM_GC}.awk"

# arquivo de controle java
FLE_JAR="/perf_01/coleta/config/console_ssh.jar"
FLE_CTL="$HOME_PATH/loader.ctl"
FLE_CTL_TMP="${DIR_HOST}/loader_tmp.ctl"
FLE_CSV="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}.csv"

# arquivo de controle java
FLE_TMP="${DIR_HOST}/${REMOTE_HOST}_${SUFFIX}.tmp"

cd 
. ./.profile

touch "$FLE_CNT_ATL" 
touch "$FLE_CNT_ANT"

echo "########################## `date '+%Y-%m-%d %T'` $REMOTE_HOST: Iniciando transferencia $SUFFIX"

java -jar $FLE_JAR ssh $REMOTE_HOST "awk -v r=0 '{if(FNR==1 && NR!=1) print r; else r = FILENAME \"|\"FNR\"|\"\$0;}END{print FILENAME\"|\"FNR\"|\"\$0;}' $REMOTE_PATH/$PREFIX*" > "$FLE_CNT_ATL"

for arquivo in $(java -jar $FLE_JAR ssh $REMOTE_HOST "find $REMOTE_PATH  -maxdepth 1 -name '$PREFIX*'"); do

    echo $arquivo

    ult_linha_anterior="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="\\|"} { if ( ARQUIVO==$1) print $2}' $FLE_CNT_ANT)"

    [ -z "$ult_linha_anterior" ] && ult_linha_anterior=0

    ult_linha_atual="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="|"} { if ( ARQUIVO==$1) print $2}' $FLE_CNT_ATL)"

    if [ $ult_linha_anterior -eq 0 ]; then

        java -jar $FLE_JAR sftp_recebe $REMOTE_HOST $arquivo $DIR_HOST

    elif [ $ult_linha_atual -ge $ult_linha_anterior ]; then

        ult_texto_anterior="$(awk -v ARQUIVO="$arquivo" 'BEGIN {FS="|"} { if ( ARQUIVO==$1) print $3}' $FLE_CNT_ANT)"

        ult_texto="$(java -jar $FLE_JAR ssh $REMOTE_HOST "head -$ult_linha_anterior $arquivo | tail -1")"

        if [ "$ult_texto" == "$ult_texto_anterior" ]; then

            numero_linha=$(expr $ult_linha_atual - $ult_linha_anterior)

            arquivo_tmp="$(echo $arquivo | sed -e 's/.*\///')"

            java -jar $FLE_JAR ssh $REMOTE_HOST "tail -n $numero_linha $arquivo > ~/$arquivo_tmp ; touch -r $arquivo ~/$arquivo_tmp"

            java -jar $FLE_JAR sftp_recebe $REMOTE_HOST $arquivo_tmp $DIR_HOST

        else

            java -jar $FLE_JAR sftp_recebe $REMOTE_HOST $arquivo $DIR_HOST

        fi

    elif [ $ult_linha_atual -lt $ult_linha_anterior ]; then

        java -jar $FLE_JAR sftp_recebe $REMOTE_HOST $arquivo $DIR_HOST

    fi
done

cat "$FLE_CNT_ATL" > "$FLE_CNT_ANT"

echo "########################## `date '+%Y-%m-%d %T'` $REMOTE_HOST: Iniciando parse $SUFFIX"

# pega lista de logs do host remoto
for arquivo in $(find $DIR_HOST/$PREFIX*  ); do

    # formatando a data de modificacao do arquivo
    fileDate=$(date -r $arquivo +%F)" "$(date -r $arquivo +%T)

    # converter a ultima data de alteracao do arquivo para timestamp
    fileTime=$(echo "$fileDate" | awk '{ gsub("\\-|:"," "); print mktime($0)}')

    awk -v FILE_TIME="$fileTime" -f $FLE_AWK $arquivo > $FLE_CSV

    awk -v V1=$SYSTEM_ID -v V2=$CONSOLE_ID -v V3=$REMOTE_HOST -v V4=$SUFFIX 'BEGIN{OFS=";";}{ print V1, V2, V3, V4, $0;}' $FLE_CSV > $FLE_TMP

    cat $FLE_TMP > $FLE_CSV

    cat $arquivo > $FLE_TMP

    rm $arquivo
done

echo "########################## `date '+%Y-%m-%d %T'` $REMOTE_HOST: Iniciando loader $SUFFIX"

awk -v FLE_CSV="${FLE_CSV}" '{gsub("##FILE##", FLE_CSV); print $0}' ${FLE_CTL} > ${FLE_CTL_TMP}

sqlldr userid="impmnegocio/intim#2011" control=${FLE_CTL_TMP} bad=${ACL_BAD} log=${ACL_LOG} errors=10000000
